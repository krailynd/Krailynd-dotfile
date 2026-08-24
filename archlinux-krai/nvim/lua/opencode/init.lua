-- OpenCode integration for LazyVim: a right-side terminal panel running the
-- opencode TUI, per-project session memory, visual-selection asks, and
-- /new-session detection via polling the opencode database.
local M = {}

local session = require("opencode.session")
local ui = require("opencode.ui")

local opts = nil
local opened_dirs = {}
local active_session = nil

local function project_dir()
  local ok, cwd = pcall(vim.fn.getcwd, -1)
  if ok and cwd and cwd ~= "" then
    return cwd
  end
  return vim.fn.getcwd()
end

function M.setup(user_opts)
  if vim.g.opencode_nvim_loaded then
    return
  end
  vim.g.opencode_nvim_loaded = true

  opts = vim.tbl_deep_extend("force", {
    -- Keep the panel manual: with auto_open=true every nvim startup launches a
    -- full opencode TUI (plus all configured MCP servers), which saturates
    -- RAM/CPU on modest machines. Open the panel on demand with <leader>io.
    auto_open = false,
    -- Full opencode TUI (slash commands, /models, etc). Needs room: 45%
    -- default, adjustable 30-80% with <leader>i= / <leader>i-.
    width = 0.45,
    min_width = 0.30,
    max_width = 0.80,
    -- Set mini=true only if you want the lightweight minimal UI instead.
    mini = false,
    poll_interval_ms = 20000,
    keymaps = {
      toggle = "<leader>io",
      pick = "<leader>is",
      focus_type = "<leader>it",
      widen = "<leader>i=",
      narrow = "<leader>i-",
      ask_visual = "<leader>ia",
    },
  }, user_opts or {})

  if not session.ensure_db() then
    vim.notify("opencode-nvim: opencode CLI or database not found; integration disabled", vim.log.levels.WARN)
    return
  end

  -- Never overwrite an existing binding: verify every keymap against what is
  -- already mapped at setup time. Conflicts are skipped and reported loudly.
  local mode_for = { toggle = "n", pick = "n", focus_type = "n", widen = "n", narrow = "n", ask_visual = "v" }
  local clean, conflicts = {}, {}
  for name, lhs in pairs(opts.keymaps) do
    if vim.fn.maparg(lhs, mode_for[name] or "n") == "" then
      clean[name] = lhs
    else
      conflicts[#conflicts + 1] = lhs .. " (" .. name .. ")"
    end
  end
  if #conflicts > 0 then
    vim.notify(
      "opencode-nvim: teclas ya ocupadas por otro plugin, NO se registran: "
        .. table.concat(conflicts, ", ")
        .. " — definí teclas libres en lua/plugins/opencode.lua bajo opts.keymaps",
      vim.log.levels.WARN
    )
  end
  opts.keymaps = clean

  M.register_keymaps()
  M.register_commands()

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      M._maybe_auto_open()
    end,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    callback = function()
      M._maybe_auto_open()
    end,
  })
end

function M.register_keymaps()
  local k = opts.keymaps
  local maps = {
    { { "n" }, k.toggle, function()
      M.toggle()
    end, "OpenCode: toggle panel" },
    { { "n" }, k.pick, function()
      M.pick()
    end, "OpenCode: pick session" },
    { { "n" }, k.focus_type, function()
      M.focus_type()
    end, "OpenCode: focus & type" },
    { { "n" }, k.widen, function()
      ui.resize(0.05, opts)
    end, "OpenCode: widen panel" },
    { { "n" }, k.narrow, function()
      ui.resize(-0.05, opts)
    end, "OpenCode: narrow panel" },
    { { "v", "x" }, k.ask_visual, function()
      M.ask_visual()
    end, "OpenCode: ask about selection" },
  }
  for _, m in ipairs(maps) do
    if m[2] and m[2] ~= "" then
      vim.keymap.set(m[1], m[2], m[3], { desc = m[4] })
    end
  end
end

function M.register_commands()
  vim.api.nvim_create_user_command("OpenCode", function()
    M.toggle()
  end, { desc = "Toggle the OpenCode panel" })
  vim.api.nvim_create_user_command("OpenCodeResize", function(args)
    local pct = tonumber(args.fargs[1])
    if not pct then
      ui.resize(0.05, opts)
      return
    end
    pct = math.max(20, math.min(80, pct))
    local target = pct / 100
    local state = ui.get_state()
    if not state or not vim.api.nvim_win_is_valid(state.win) then
      return
    end
    local current = vim.api.nvim_win_get_width(state.win) / vim.o.columns
    ui.resize(target - current, opts)
  end, { desc = "OpenCode: resize panel (percent 20-80)", nargs = "?" })
end

function M.toggle()
  if ui.is_open() then
    M.close()
  else
    M._open({ resume = true })
  end
end

function M.close()
  ui.close()
  active_session = nil
end

-- Jump straight into the opencode panel ready to type: focus the terminal
-- window and enter terminal mode (t) so keystrokes go to the TUI. If no
-- panel/session is open, error with a hint instead of silently doing nothing.
function M.focus_type()
  local st = ui.get_state()
  if st and vim.api.nvim_win_is_valid(st.win) then
    -- WinEnter autocmd already enters terminal mode; startinsert is a direct
    -- no-op-safe fallback. NO feedkeys("i") fallback: if startinsert already
    -- worked it would type a literal "i" into the opencode input.
    ui.focus()
    vim.cmd("startinsert")
    return
  end
  local hint = opts and opts.keymaps and opts.keymaps.toggle or "<leader>io"
  vim.notify(
    "No hay ninguna sesión de OpenCode abierta — abrí el panel con " .. hint,
    vim.log.levels.ERROR,
    { title = "OpenCode" }
  )
end

function M.resize(delta_pct)
  ui.resize(delta_pct, opts)
end

-- Resolve which session to resume for a project, shared by the fresh-open path
-- (_open) and the restored-session adoption path (_maybe_auto_open).
-- open_opts.session_id: explicit session (pick); force_new: no resume.
function M._resolve_session(dir, open_opts)
  open_opts = open_opts or {}
  local session_id, resume_title = nil, nil
  if open_opts.session_id then
    session_id = open_opts.session_id
    for _, s in ipairs(session.list_sessions(dir)) do
      if s.id == session_id then
        resume_title = s.title
        break
      end
    end
  elseif not open_opts.force_new then
    local remembered = session.load_state(dir)
    if remembered.last_session_id then
      for _, s in ipairs(session.list_sessions(dir)) do
        if s.id == remembered.last_session_id then
          session_id = s.id
          resume_title = s.title
          break
        end
      end
    end
    if not session_id then
      local latest = session.get_latest(dir)
      if latest then
        session_id = latest.id
        resume_title = latest.title
      end
    end
  end
  return session_id, resume_title
end

-- Open (or focus) the panel for the current project.
-- resume: prefer the remembered/latest session when not force_new.
-- session_id: resume this exact session.
-- pending_send: paste this text into opencode's input after the panel opens.
-- force_new: start opencode with no -s flag (a brand-new session).
function M._open(open_opts)
  open_opts = open_opts or {}
  local dir = project_dir()

  local state = ui.get_state()
  if state and vim.api.nvim_win_is_valid(state.win) and state.dir == dir then
    ui.focus()
    if open_opts.pending_send then
      vim.defer_fn(function()
        if ui.is_open() and ui.get_state().dir == dir then
          ui.send_text(open_opts.pending_send)
        end
      end, 200)
    end
    return
  end
  local session_id, resume_title = M._resolve_session(dir, open_opts)

  -- Baseline used by the poller to detect /new sessions: the id we are
  -- resuming, or the current latest id when starting fresh.
  local baseline = session_id
  if not baseline then
    local latest = session.get_latest(dir)
    baseline = latest and latest.id or nil
  end
  active_session = { id = baseline, title = resume_title or "", dir = dir }

  local ok_open, created = pcall(ui.open, dir, {
    width = opts.width,
    min_width = opts.min_width,
    max_width = opts.max_width,
    mini = opts.mini,
    session_id = session_id,
  })
  if not ok_open or not created then
    active_session = nil
    if not ok_open then
      vim.notify(
        "OpenCode: error al abrir el panel — " .. tostring(created),
        vim.log.levels.ERROR,
        { title = "OpenCode" }
      )
    end
    return
  end

  if session_id then
    session.remember(dir, session_id, resume_title or "", "resume")
    local label = (resume_title ~= nil and resume_title ~= "") and resume_title or session_id
    vim.notify("OpenCode: sesión reanudada — " .. label, vim.log.levels.INFO, { title = "OpenCode" })
  else
    vim.notify("OpenCode: sesión nueva en " .. vim.fn.fnamemodify(dir, ":t"), vim.log.levels.INFO, { title = "OpenCode" })
  end
  opened_dirs[dir] = true
  M._start_poll(dir)

  if open_opts.pending_send then
    vim.defer_fn(function()
      if ui.is_open() and ui.get_state().dir == dir then
        ui.focus()
        ui.send_text(open_opts.pending_send)
      end
    end, 600)
  end
end

-- Poll the database while the panel is open. When the most recent session id
-- changes (user typed /new inside opencode, or a session was updated), record
-- it so the state file always points at the newest session.
function M._poll()
  local state = ui.get_state()
  if not state or not vim.api.nvim_win_is_valid(state.win) then
    return
  end
  local list = session.list_sessions(state.dir)
  local first = list[1]
  if not first then
    return
  end
  local prev = active_session and active_session.id or nil
  if first.id ~= prev then
    local reason = prev == nil and "new" or "updated"
    session.remember(state.dir, first.id, first.title or "", reason)
    active_session = { id = first.id, title = first.title or "", dir = state.dir }
  end
end

function M._start_poll(dir)
  ui.stop_poll()
  local handle = vim.fn.timer_start(opts.poll_interval_ms, function()
    M._poll()
  end, { ["repeat"] = -1 })
  ui.set_poll_timer(handle)
end

function M.pick()
  local dir = project_dir()
  local list = session.list_sessions(dir)
  if #list == 0 then
    vim.notify("Sin sesiones para este proyecto", vim.log.levels.INFO)
    M._open({ force_new = true })
    return
  end
  local items = {}
  for _, s in ipairs(list) do
    items[#items + 1] = (s.title or "") .. "  (" .. s.id .. ")"
  end
  vim.ui.select(items, {
    prompt = "OpenCode sessions (" .. vim.fn.fnamemodify(dir, ":t") .. ")",
  }, function(choice, idx)
    if choice and idx and list[idx] then
      M._open({ session_id = list[idx].id })
    end
  end)
end

-- Visual-mode ask: capture the selection, build a code-context message, and
-- paste it into opencode's input WITHOUT submitting (user edits before send).
function M.ask_visual()
  local dir = project_dir()
  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")

  local ok, res = pcall(vim.fn.getregion, s, e, { type = vim.fn.mode() })
  local lines
  if ok and type(res) == "table" then
    lines = res
  else
    vim.cmd('normal! gv"zy')
    lines = vim.split(vim.fn.getreg("z"), "\n")
  end
  if not lines or #lines == 0 then
    vim.notify("Pregunta vacía, cancelado", vim.log.levels.INFO)
    return
  end

  local relative = vim.fn.expand("%")
  local filetype = vim.bo.filetype
  local start_line = s[2] or 1
  local end_line = e[2] or start_line

  ui.input({ prompt = "Pregunta a opencode", title = "OpenCode", icon = "󰒲" }, function(input)
    if not input or input == "" then
      vim.notify("Pregunta vacía, cancelado", vim.log.levels.INFO)
      return
    end
    local msg = table.concat({
      "[Código seleccionado de " .. relative .. ":" .. start_line .. "-" .. end_line .. "]",
      "",
      "```" .. filetype,
      table.concat(lines, "\n"),
      "```",
      "",
      input,
    }, "\n")
    M._dispatch_ask(dir, msg)
  end)
end

function M._dispatch_ask(dir, msg)
  local state = ui.get_state()
  if state and vim.api.nvim_win_is_valid(state.win) and state.dir == dir then
    ui.focus()
    ui.send_text(msg)
    return
  end
  if session.get_latest(dir) then
    M._open({ resume = true, pending_send = msg })
    return
  end
  ui.confirm_yn("No hay ninguna sesión de opencode para este proyecto. ¿Crear una sesión nueva?", function()
    M._open({ force_new = true, pending_send = msg })
  end)
end

function M._maybe_auto_open()
  if not vim.g.opencode_nvim_loaded then
    return
  end
  if not opts or not opts.auto_open then
    -- Panel is manual: never launch opencode from startup. Still sweep any
    -- restored dead panel terminal (from a persisted session) so no zombie
    -- window lingers next to the restored files; <leader>io reopens fresh.
    local dir = project_dir()
    if ui.has_opencode_term() then
      ui.adopt_restored(dir, {
        width = opts.width,
        min_width = opts.min_width,
        max_width = opts.max_width,
        mini = opts.mini,
      })
    end
    return
  end
  if ui.is_open() then
    return
  end
  local dir = project_dir()
  if opened_dirs[dir] then
    return
  end

  -- A restored session (persistence.nvim) may already carry the OpenCode
  -- terminal. adopt_restored adopts a live one in place, or wipes dead
  -- restored zombies (termopen cannot resurrect them) and reports wiped=true
  -- so we open a fresh panel on the same right edge instead of duplicating.
  local session_id, resume_title = M._resolve_session(dir, { resume = true })
  local adopted, wiped = ui.adopt_restored(dir, {
    width = opts.width,
    min_width = opts.min_width,
    max_width = opts.max_width,
    mini = opts.mini,
    session_id = session_id,
  })
  if adopted then
    if session_id then
      session.remember(dir, session_id, resume_title or "", "resume")
      local label = (resume_title ~= nil and resume_title ~= "") and resume_title or session_id
      vim.notify("OpenCode: sesión reanudada — " .. label, vim.log.levels.INFO, { title = "OpenCode" })
    else
      vim.notify("OpenCode: sesión nueva en " .. vim.fn.fnamemodify(dir, ":t"), vim.log.levels.INFO, { title = "OpenCode" })
    end
    local baseline = session_id
    if not baseline then
      local latest = session.get_latest(dir)
      baseline = latest and latest.id or nil
    end
    active_session = { id = baseline, title = resume_title or "", dir = dir }
    opened_dirs[dir] = true
    M._start_poll(dir)
    return
  end

  if wiped or session.get_latest(dir) then
    M._open({ resume = true })
  end
end

return M