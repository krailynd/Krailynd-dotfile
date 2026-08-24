-- Triple toggleable terminals: left-bottom (below explorer), floating centered, right lateral.
-- Mirrors patterns from lua/opencode/ui.lua and lua/sahadisk/ui.lua:
-- - persistent terminal buffers (bufhidden=hide, not wiped on hide)
-- - hygiene (no number/signcolumn/etc)
-- - WinEnter auto-enters terminal mode
-- - Esc Esc leaves terminal -> previous code window (keeps terminal alive)
-- - global Esc Esc in normal mode returns to last active terminal
local M = {}

M.state = {
  left = nil,
  center = nil,
  right = nil,
  last = nil, -- "left" | "center" | "right"
}

local function is_valid_win(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
  return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

local function job_running(chan)
  if not chan or chan <= 0 then
    return false
  end
  local ok, res = pcall(vim.fn.jobwait, { chan }, 0)
  if not ok or type(res) ~= "table" then
    return false
  end
  return res[1] == -1
end

local function is_term_alive(buf)
  if not is_valid_buf(buf) then
    return false
  end
  if vim.bo[buf].buftype ~= "terminal" then
    return false
  end
  local chan = vim.b[buf].terminal_job_id or vim.b[buf].term_jobid
  -- If no channel info, assume alive (headless test may not have term_jobid yet)
  if not chan then
    return true
  end
  return job_running(chan)
end

local function make_state(win, buf, chan)
  return { win = win, buf = buf, chan = chan }
end

-- Explorer filetypes that occupy the left sidebar.
local EXPLORER_FILETYPES = {
  ["neo-tree"] = true,
  ["neo-tree-popup"] = true,
  ["NvimTree"] = true,
  ["nvim-tree"] = true,
  ["minifiles"] = true,
  ["snacks_picker_list"] = true,
  ["snacks_picker_input"] = true,
  ["snacks_layout_box"] = true,
  ["snacks_explorer"] = true,
  ["oil"] = true,
}

local function find_explorer_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if EXPLORER_FILETYPES[ft] then
      return win
    end
    -- Fallback: Snacks explorer windows are marked with snacks_win.position == "left"
    -- but we must exclude our own terminal windows (buftype == terminal)
    if vim.w[win].snacks_win and vim.w[win].snacks_win.position == "left" then
      if vim.bo[buf].buftype ~= "terminal" and ft ~= "snacks_terminal" then
        return win
      end
    end
  end
  return nil
end

-- Find the main editor (code) window, skipping explorer sidebars and terminals.
-- Skips: explorer filetypes, Snacks left sidebar (snacks_win.position == "left"),
-- terminal buffers (buftype == "terminal" or ft == "snacks_terminal"), and floating windows.
-- Returns the first remaining normal code window (buftype == "" and filetype ~= "").
-- Falls back to the largest non-explorer/non-terminal window if no candidate found.
local function find_editor_win()
  local wins = vim.api.nvim_list_wins()
  local largest_win = nil
  local largest_area = -1
  for _, win in ipairs(wins) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" then
      -- Skip floating windows.
    else
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      local is_explorer = EXPLORER_FILETYPES[ft] == true
      local is_snacks_left = vim.w[win].snacks_win and vim.w[win].snacks_win.position == "left"
      local is_terminal = bt == "terminal" or ft == "snacks_terminal"
      if is_explorer or is_snacks_left or is_terminal then
        -- Skip explorer and terminal windows.
      else
        if bt == "" and ft ~= "" then
          return win
        end
        -- Track largest window as fallback.
        local ok_w, w = pcall(vim.api.nvim_win_get_width, win)
        local ok_h, h = pcall(vim.api.nvim_win_get_height, win)
        if ok_w and ok_h then
          local area = w * h
          if area > largest_area then
            largest_area = area
            largest_win = win
          end
        end
      end
    end
  end
  if largest_win and is_valid_win(largest_win) then
    return largest_win
  end
  return nil
end

local function apply_hygiene(win, buf)
  if not is_valid_win(win) then
    return
  end
  buf = buf or vim.api.nvim_win_get_buf(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].list = false
  vim.wo[win].cursorline = false
  vim.wo[win].cursorcolumn = false
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].foldenable = false
  vim.wo[win].spell = false
  vim.wo[win].wrap = false
  vim.wo[win].winblend = 0
  vim.wo[win].winbar = " "
  vim.wo[win].statusline = " "
  vim.wo[win].winhighlight = "Normal:Normal,NormalNC:Normal,FloatBorder:FloatBorder,WinSeparator:WinSeparator,CursorLine:Normal,CursorColumn:Normal"
  if is_valid_buf(buf) then
    pcall(function()
      vim.bo[buf].syntax = ""
    end)
    -- Disable highlighters that paint the terminal as code (yellow)
    vim.b[buf].minihipatterns_disable = true
    vim.b[buf].minicursorword_disable = true
    vim.b[buf].ts_highlight = false
    pcall(vim.treesitter.stop, buf)
  end
end

local function cleanup_state(state_ref, state)
  if not state then
    return
  end
  if state.cleaning then
    return
  end
  state.cleaning = true
  if M.state[state_ref] == state then
    M.state[state_ref] = nil
    if M.state.last == state_ref then
      M.state.last = nil
    end
  end
  if is_valid_win(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  if is_valid_buf(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
end

-- Buffer-local bindings shared by every terminal: auto-insert on WinEnter,
-- double-Esc back to previous code window, TermClose cleanup.
local function bind_terminal(buf, state, kind)
  -- Mark buffer so we can identify it as our terminal
  vim.b[buf].terminal_marker = kind
  vim.b[buf].terminal_kind = kind
  -- Immediately disable code highlighters for this terminal buffer
  vim.b[buf].minihipatterns_disable = true
  vim.b[buf].minicursorword_disable = true
  vim.b[buf].ts_highlight = false
  pcall(vim.treesitter.stop, buf)
  pcall(function()
    vim.bo[buf].syntax = ""
  end)

  vim.api.nvim_create_autocmd("TermOpen", {
    buffer = buf,
    once = true,
    callback = function()
      if is_valid_win(state.win) then
        apply_hygiene(state.win, buf)
      end
      -- Re-apply buffer hygiene after terminal job starts
      vim.b[buf].minihipatterns_disable = true
      pcall(vim.treesitter.stop, buf)
    end,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    buffer = buf,
    callback = function()
      if vim.bo[buf].buftype == "terminal" and vim.api.nvim_get_current_buf() == buf then
        vim.cmd("startinsert")
      end
    end,
  })

  -- Leave terminal -> editor window (skip explorer), keep terminal alive (hide, not wipe).
  vim.keymap.set("t", "<Esc><Esc>", function()
    -- Exit terminal mode.
    pcall(vim.cmd, "stopinsert")
    pcall(function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
    end)
    local editor = find_editor_win()
    if editor and is_valid_win(editor) then
      pcall(vim.api.nvim_set_current_win, editor)
    else
      -- Fallback to previous window.
      pcall(vim.cmd, "wincmd p")
      -- If fallback landed on explorer/terminal, try editor again.
      local cur = vim.api.nvim_get_current_win()
      if is_valid_win(cur) then
        local cur_buf = vim.api.nvim_win_get_buf(cur)
        local cur_ft = vim.bo[cur_buf].filetype
        local cur_bt = vim.bo[cur_buf].buftype
        local is_exp = EXPLORER_FILETYPES[cur_ft] == true
        local is_left = vim.w[cur] and vim.w[cur].snacks_win and vim.w[cur].snacks_win.position == "left"
        local is_term = cur_bt == "terminal" or cur_ft == "snacks_terminal"
        if is_exp or is_left or is_term then
          local alt = find_editor_win()
          if alt and is_valid_win(alt) and alt ~= cur then
            pcall(vim.api.nvim_set_current_win, alt)
          end
        end
      end
    end
  end, {
    buffer = buf,
    desc = "Terminal " .. kind .. ": leave & return to code",
  })

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      -- If window already closed (hidden), cleanup state. Otherwise let close handle it.
      if not is_valid_win(state.win) then
        cleanup_state(kind, state)
      else
        -- Terminal job exited while window visible: close window and cleanup buf
        vim.schedule(function()
          cleanup_state(kind, state)
        end)
      end
    end,
  })
end

-- ========== LEFT (abajo del explorer, mitad altura) ==========

local function hide_left()
  local st = M.state.left
  if st and is_valid_win(st.win) then
    pcall(vim.api.nvim_win_close, st.win, true)
  end
  if st then
    st.win = nil
  end
end

local function show_left_existing()
  local st = M.state.left
  if not st or not is_valid_buf(st.buf) or not is_term_alive(st.buf) then
    return false
  end
  local buf = st.buf
  local explorer_win = find_explorer_win()
  local win
  if explorer_win and is_valid_win(explorer_win) then
    -- Split below the explorer window and reuse buffer (win_call ensures Snacks layout boxes split in correct column)
    local exp_h_before = vim.api.nvim_win_get_height(explorer_win)
    local ok = pcall(vim.api.nvim_win_call, explorer_win, function()
      local before = vim.api.nvim_list_wins()
      vim.cmd("belowright split")
      local after = vim.api.nvim_list_wins()
      for _, w in ipairs(after) do
        local found = false
        for _, b in ipairs(before) do
          if w == b then
            found = true
            break
          end
        end
        if not found then
          win = w
          break
        end
      end
      if not win then
        win = vim.api.nvim_get_current_win()
      end
      vim.api.nvim_win_set_buf(win, buf)
      local h = math.max(8, math.floor(exp_h_before * 0.5))
      pcall(vim.api.nvim_win_set_height, win, h)
      pcall(vim.api.nvim_win_set_height, explorer_win, h)
    end)
    if not ok or not win then
      vim.cmd("belowright split")
      win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(win, buf)
      pcall(vim.api.nvim_win_set_height, win, 12)
    end
    vim.wo[win].winfixheight = true
    vim.wo[win].winfixwidth = true
  else
    vim.cmd("belowright split")
    win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, buf)
    pcall(vim.api.nvim_win_set_height, win, 12)
    vim.wo[win].winfixheight = true
  end
  st.win = win
  apply_hygiene(win, buf)
  pcall(vim.api.nvim_set_current_win, win)
  vim.cmd("startinsert")
  M.state.last = "left"
  return true
end

local function create_left()
  local explorer_win = find_explorer_win()
  local win, buf
  if explorer_win and is_valid_win(explorer_win) then
    -- Create split below explorer (win_call ensures Snacks layout boxes split in correct column)
    local exp_h_before = vim.api.nvim_win_get_height(explorer_win)
    local exp_w = vim.api.nvim_win_get_width(explorer_win)
    buf = vim.api.nvim_create_buf(false, true)
    local ok = pcall(vim.api.nvim_win_call, explorer_win, function()
      local before = vim.api.nvim_list_wins()
      vim.cmd("belowright split")
      local after = vim.api.nvim_list_wins()
      for _, w in ipairs(after) do
        local found = false
        for _, b in ipairs(before) do
          if w == b then
            found = true
            break
          end
        end
        if not found then
          win = w
          break
        end
      end
      if not win then
        win = vim.api.nvim_get_current_win()
      end
      vim.api.nvim_win_set_buf(win, buf)
      local h = math.max(8, math.floor(exp_h_before * 0.5))
      pcall(vim.api.nvim_win_set_height, win, h)
      pcall(vim.api.nvim_win_set_height, explorer_win, h)
      pcall(vim.api.nvim_win_set_width, win, exp_w)
    end)
    if not ok or not is_valid_win(win) then
      vim.api.nvim_set_current_win(explorer_win)
      vim.cmd("belowright split")
      win = vim.api.nvim_get_current_win()
      if not is_valid_buf(buf) then
        buf = vim.api.nvim_create_buf(false, true)
      end
      vim.api.nvim_win_set_buf(win, buf)
      local h = math.max(8, math.floor(exp_h_before * 0.5))
      pcall(vim.api.nvim_win_set_height, win, h)
      pcall(vim.api.nvim_win_set_height, explorer_win, h)
      pcall(vim.api.nvim_win_set_width, win, exp_w)
    end
    vim.wo[win].winfixheight = true
    vim.wo[win].winfixwidth = true
  else
    vim.cmd("belowright split")
    win = vim.api.nvim_get_current_win()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    pcall(vim.api.nvim_win_set_height, win, 12)
    vim.wo[win].winfixheight = true
  end

  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false

  apply_hygiene(win, buf)

  local state = make_state(win, buf, nil)
  M.state.left = state

  -- Execute shell in buffer
  vim.api.nvim_set_current_win(win)
  -- Ensure buffer is current
  vim.api.nvim_set_current_buf(buf)
  local shell = vim.o.shell
  local chan = vim.fn.termopen(shell, {
    on_exit = function()
      cleanup_state("left", state)
    end,
  })
  if not chan or chan <= 0 then
    cleanup_state("left", state)
    vim.notify("Terminal izquierda: no se pudo iniciar el shell", vim.log.levels.ERROR)
    return nil
  end
  state.chan = chan

  bind_terminal(buf, state, "left")

  if vim.api.nvim_get_current_win() == win then
    vim.cmd("startinsert")
  end
  M.state.last = "left"
  return state
end

function M.toggle_left()
  local st = M.state.left
  if st and is_valid_win(st.win) then
    hide_left()
    M.state.last = "left"
    return
  end
  if st and is_valid_buf(st.buf) then
    if not is_term_alive(st.buf) then
      cleanup_state("left", st)
      create_left()
      return
    end
    show_left_existing()
    return
  end
  create_left()
end

function M.is_left_open()
  return M.state.left ~= nil and is_valid_win(M.state.left.win)
end

-- ========== RIGHT (lateral derecho) ==========

local function hide_right()
  local st = M.state.right
  if st and is_valid_win(st.win) then
    pcall(vim.api.nvim_win_close, st.win, true)
  end
  if st then
    st.win = nil
  end
end

local function show_right_existing()
  local st = M.state.right
  if not st or not is_valid_buf(st.buf) or not is_term_alive(st.buf) then
    return false
  end
  local buf = st.buf
  vim.cmd("botright vertical new")
  local win = vim.api.nvim_get_current_win()
  -- Replace the empty buffer created by :new with our terminal buffer
  local tmp = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_buf(win, buf)
  if is_valid_buf(tmp) and tmp ~= buf then
    pcall(vim.api.nvim_buf_delete, tmp, { force = true })
  end
  local frac = 0.35
  local cols = vim.o.columns
  pcall(vim.api.nvim_win_set_width, win, math.floor(cols * frac))
  vim.wo[win].winfixwidth = true
  vim.wo[win].winfixheight = false
  st.win = win
  apply_hygiene(win, buf)
  pcall(vim.api.nvim_set_current_win, win)
  vim.cmd("startinsert")
  M.state.last = "right"
  return true
end

local function create_right()
  vim.cmd("botright vertical new")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
  -- The :new already created a buffer; reuse it
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false

  apply_hygiene(win, buf)
  local frac = 0.35
  frac = math.max(0.20, math.min(0.80, frac))
  pcall(vim.api.nvim_win_set_width, win, math.floor(vim.o.columns * frac))
  vim.wo[win].winfixwidth = true

  local state = make_state(win, buf, nil)
  M.state.right = state

  local shell = vim.o.shell
  local chan = vim.fn.termopen(shell, {
    on_exit = function()
      cleanup_state("right", state)
    end,
  })
  if not chan or chan <= 0 then
    cleanup_state("right", state)
    vim.notify("Terminal derecha: no se pudo iniciar el shell", vim.log.levels.ERROR)
    return nil
  end
  state.chan = chan

  bind_terminal(buf, state, "right")

  if vim.api.nvim_get_current_win() == win then
    vim.cmd("startinsert")
  end
  M.state.last = "right"
  return state
end

function M.toggle_right()
  local st = M.state.right
  if st and is_valid_win(st.win) then
    hide_right()
    M.state.last = "right"
    return
  end
  if st and is_valid_buf(st.buf) then
    if not is_term_alive(st.buf) then
      cleanup_state("right", st)
      create_right()
      return
    end
    show_right_existing()
    return
  end
  create_right()
end

function M.is_right_open()
  return M.state.right ~= nil and is_valid_win(M.state.right.win)
end

-- ========== CENTER (flotante centrada) ==========

local function hide_center()
  local st = M.state.center
  if st and is_valid_win(st.win) then
    pcall(vim.api.nvim_win_close, st.win, true)
  end
  if st then
    st.win = nil
  end
end

local function show_center_existing()
  local st = M.state.center
  if not st or not is_valid_buf(st.buf) or not is_term_alive(st.buf) then
    return false
  end
  local buf = st.buf
  local cols = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(cols * 0.80)
  local height = math.floor(lines * 0.80)
  local row = math.floor((lines - height) / 2)
  local col = math.floor((cols - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Terminal Flotante ",
    title_pos = "center",
    zindex = 50,
  })
  st.win = win
  apply_hygiene(win, buf)
  -- Floating hygiene already minimal
  vim.cmd("startinsert")
  M.state.last = "center"
  return true
end

local function create_center()
  local cols = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(cols * 0.80)
  local height = math.floor(lines * 0.80)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((lines - height) / 2),
    col = math.floor((cols - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Terminal Flotante ",
    title_pos = "center",
    zindex = 50,
  })

  apply_hygiene(win, buf)

  local state = make_state(win, buf, nil)
  M.state.center = state

  local shell = vim.o.shell
  -- Need to set current win/buf for termopen to attach correctly
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_set_current_buf(buf)
  local chan = vim.fn.termopen(shell, {
    on_exit = function()
      cleanup_state("center", state)
    end,
  })
  if not chan or chan <= 0 then
    cleanup_state("center", state)
    vim.notify("Terminal flotante: no se pudo iniciar el shell", vim.log.levels.ERROR)
    return nil
  end
  state.chan = chan

  bind_terminal(buf, state, "center")

  if vim.api.nvim_get_current_win() == win then
    vim.cmd("startinsert")
  end
  M.state.last = "center"
  return state
end

function M.toggle_center()
  local st = M.state.center
  if st and is_valid_win(st.win) then
    hide_center()
    M.state.last = "center"
    return
  end
  if st and is_valid_buf(st.buf) then
    if not is_term_alive(st.buf) then
      cleanup_state("center", st)
      create_center()
      return
    end
    show_center_existing()
    return
  end
  create_center()
end

function M.is_center_open()
  return M.state.center ~= nil and is_valid_win(M.state.center.win)
end

-- ========== General helpers ==========

function M.is_any_open()
  return M.is_left_open() or M.is_right_open() or M.is_center_open()
end

function M.focus_last()
  local last = M.state.last
  -- Prefer last (only if alive)
  if last and M.state[last] and is_valid_buf(M.state[last].buf) and is_term_alive(M.state[last].buf) then
    if is_valid_win(M.state[last].win) then
      pcall(vim.api.nvim_set_current_win, M.state[last].win)
      vim.cmd("startinsert")
      return true
    else
      -- Recreate window for hidden terminal
      if last == "left" then
        if show_left_existing() ~= false then
          return true
        end
      elseif last == "right" then
        if show_right_existing() ~= false then
          return true
        end
      elseif last == "center" then
        if show_center_existing() ~= false then
          return true
        end
      end
    end
  end
  -- Fallback: any visible (alive checked via win implies buf alive, but double-check)
  for _, k in ipairs({ "right", "left", "center" }) do
    local st = M.state[k]
    if st and is_valid_win(st.win) and is_valid_buf(st.buf) and is_term_alive(st.buf) then
      pcall(vim.api.nvim_set_current_win, st.win)
      vim.cmd("startinsert")
      M.state.last = k
      return true
    end
  end
  -- Fallback: any hidden buffer (alive)
  for _, k in ipairs({ "right", "left", "center" }) do
    local st = M.state[k]
    if st and is_valid_buf(st.buf) and is_term_alive(st.buf) then
      if k == "left" then
        if show_left_existing() then
          return true
        end
      elseif k == "right" then
        if show_right_existing() then
          return true
        end
      elseif k == "center" then
        if show_center_existing() then
          return true
        end
      end
    end
  end
  return false
end

function M.close_all()
  for _, k in ipairs({ "left", "right", "center" }) do
    local st = M.state[k]
    if st then
      cleanup_state(k, st)
    end
  end
  M.state.last = nil
end

-- Setup global keymaps and autocmds for layout correction
function M.setup(opts)
  if vim.g.terminal_triple_loaded then
    return
  end
  vim.g.terminal_triple_loaded = true

  opts = opts or {}

  -- Ensure terminal buffers persist across sessions
  vim.opt.sessionoptions:append("terminal")

  -- which-key group (safe even if which-key not loaded)
  pcall(function()
    local wk = require("which-key")
    wk.add({
      { "<leader>p", group = "Terminal/Panel" },
    })
  end)

  -- Toggle keymaps with conflict check (like opencode)
  local keymaps = vim.tbl_deep_extend("force", {
    left = "<leader>pl",
    center = "<leader>pc",
    right = "<leader>pr",
  }, opts.keymaps or {})

  local function safe_map(mode, lhs, rhs, desc)
    if lhs == nil or lhs == "" then
      return
    end
    if vim.fn.maparg(lhs, mode) ~= "" then
      vim.notify(
        "terminal: tecla " .. lhs .. " ya ocupada, no se registra (" .. desc .. ")",
        vim.log.levels.WARN
      )
      return
    end
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
  end

  safe_map("n", keymaps.left, function()
    M.toggle_left()
  end, "Terminal izquierda (abajo explorer)")

  safe_map("n", keymaps.center, function()
    M.toggle_center()
  end, "Terminal flotante (centro)")

  safe_map("n", keymaps.right, function()
    M.toggle_right()
  end, "Terminal derecha")

  -- Focus shortcuts: return to explorer / return to terminal (explicit)
  safe_map("n", "<leader>pe", function()
    local win = find_explorer_win()
    if win and is_valid_win(win) then
      pcall(vim.api.nvim_set_current_win, win)
    else
      -- Explorer not visible: try to open it (neo-tree or snacks)
      local opened = false
      if pcall(function() vim.cmd("Neotree show") end) then opened = true end
      if not opened then pcall(function() require("snacks").explorer() end) end
      if not opened then vim.notify("Explorer no encontrado", vim.log.levels.WARN) end
    end
  end, "Ir al explorador (foco)")

  safe_map("n", "<leader>pt", function()
    if not M.focus_last() then
      vim.notify("No hay terminal activa (usa <leader>pl/pc/pr para abrir)", vim.log.levels.INFO)
    end
  end, "Ir a la terminal (última activa)")

  -- Also support toggle from terminal mode via same lhs (optional, but keep Esc Esc primary)
  -- Global Esc Esc in normal mode -> return to last terminal
  if vim.fn.maparg("<Esc><Esc>", "n") == "" then
    vim.keymap.set("n", "<Esc><Esc>", function()
      if not M.focus_last() then
        -- No terminal to focus: clear hlsearch (fallback like LazyVim <esc>)
        vim.cmd("nohlsearch")
        -- Stop snippet if luasnip available (like LazyVim default)
        pcall(function()
          if require("luasnip").expand_or_jumpable() then
            vim.snippet.stop()
          end
        end)
      end
    end, { desc = "Terminal: volver a la ultima terminal activa (Esc Esc)" })
  else
    -- If already mapped, create alternative <leader><Esc> ?
    vim.notify("terminal: <Esc><Esc> en modo normal ya esta mapeado, no se sobreescribe", vim.log.levels.DEBUG)
  end

  -- Autocmd to fix left terminal layout when explorer appears
  -- When a neo-tree / minifiles / oil / snacks explorer buffer appears, if left terminal is visible,
  -- ensure it is positioned below explorer (same column, below).
  local explorer_patterns = {
    "neo-tree",
    "neo-tree-popup",
    "minifiles",
    "oil",
    "snacks_picker_list",
    "snacks_picker_input",
    "snacks_layout_box",
    "snacks_explorer",
    "NvimTree",
  }
  vim.api.nvim_create_autocmd("FileType", {
    pattern = explorer_patterns,
    callback = function()
      vim.schedule(function()
        local st = M.state.left
        if not st or not is_valid_win(st.win) then
          return
        end
        local explorer_win = find_explorer_win()
        if not explorer_win or not is_valid_win(explorer_win) then
          return
        end
        if explorer_win == st.win then
          return
        end
        -- Check if they are already stacked vertically in same column
        local exp_pos = vim.api.nvim_win_get_position(explorer_win)
        local term_pos = vim.api.nvim_win_get_position(st.win)
        local exp_col = exp_pos[2]
        local term_col = term_pos[2]
        local exp_row = exp_pos[1]
        local term_row = term_pos[1]
        -- Same column and terminal below explorer -> correct
        if exp_col == term_col and term_row > exp_row then
          return
        end
        -- Otherwise reposition: hide and show again below explorer
        -- Avoid loop: only do if not already correct
        hide_left()
        vim.schedule(function()
          if st and is_valid_buf(st.buf) then
            show_left_existing()
          end
        end)
      end)
    end,
  })

  -- Also handle BufWinEnter for explorers that may not trigger FileType again (e.g., Snacks layout boxes)
  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if not EXPLORER_FILETYPES[ft] then
        -- Fallback check for Snacks layout left sidebar (may have empty ft but snacks_win marker)
        local win = vim.fn.bufwinid(args.buf)
        if win < 0 or not vim.w[win] or not vim.w[win].snacks_win or vim.w[win].snacks_win.position ~= "left" then
          return
        end
      end
      vim.schedule(function()
        local st = M.state.left
        if not st or not is_valid_win(st.win) then
          return
        end
        local explorer_win = find_explorer_win()
        if not explorer_win or not is_valid_win(explorer_win) or explorer_win == st.win then
          return
        end
        local exp_pos = vim.api.nvim_win_get_position(explorer_win)
        local term_pos = vim.api.nvim_win_get_position(st.win)
        if exp_pos[2] == term_pos[2] and term_pos[1] > exp_pos[1] then
          return
        end
        hide_left()
        vim.schedule(function()
          if st and is_valid_buf(st.buf) then
            show_left_existing()
          end
        end)
      end)
    end,
  })

  -- Explorer Esc Esc -> editor (buffer-local, shadows global Esc Esc).
  -- Uses same EXPLORER_FILETYPES list and snacks_win check as find_editor_win.
  local explorer_esc_patterns = {
    "neo-tree",
    "neo-tree-popup",
    "NvimTree",
    "nvim-tree",
    "minifiles",
    "snacks_picker_list",
    "snacks_picker_input",
    "snacks_layout_box",
    "snacks_explorer",
    "oil",
  }
  vim.api.nvim_create_autocmd("FileType", {
    pattern = explorer_esc_patterns,
    callback = function(args)
      local b = args.buf
      vim.keymap.set("n", "<Esc><Esc>", function()
        local editor = find_editor_win()
        if editor and is_valid_win(editor) then
          pcall(vim.api.nvim_set_current_win, editor)
        else
          pcall(vim.cmd, "wincmd p")
          local cur = vim.api.nvim_get_current_win()
          if is_valid_win(cur) then
            local cur_buf = vim.api.nvim_win_get_buf(cur)
            local cur_ft = vim.bo[cur_buf].filetype
            local cur_bt = vim.bo[cur_buf].buftype
            local is_exp = EXPLORER_FILETYPES[cur_ft] == true
            local is_left = vim.w[cur] and vim.w[cur].snacks_win and vim.w[cur].snacks_win.position == "left"
            local is_term = cur_bt == "terminal" or cur_ft == "snacks_terminal"
            if is_exp or is_left or is_term then
              local alt = find_editor_win()
              if alt and is_valid_win(alt) and alt ~= cur then
                pcall(vim.api.nvim_set_current_win, alt)
              end
            end
          end
        end
      end, { buffer = b, desc = "Explorer: volver al editor", silent = true })
    end,
  })

  -- Fallback for Snacks left sidebar windows without explorer filetype
  -- (e.g., snacks_layout_box with empty ft but snacks_win.position == "left").
  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(args)
      local win = vim.fn.bufwinid(args.buf)
      if win < 0 or not is_valid_win(win) then
        return
      end
      -- Only act on left sidebar that is not already an explorer filetype.
      local sw = vim.w[win] and vim.w[win].snacks_win
      if not (sw and sw.position == "left") then
        return
      end
      local ft = vim.bo[args.buf].filetype
      local bt = vim.bo[args.buf].buftype
      if bt == "terminal" or ft == "snacks_terminal" or EXPLORER_FILETYPES[ft] then
        return
      end
      vim.keymap.set("n", "<Esc><Esc>", function()
        local editor = find_editor_win()
        if editor and is_valid_win(editor) then
          pcall(vim.api.nvim_set_current_win, editor)
        else
          pcall(vim.cmd, "wincmd p")
        end
      end, { buffer = args.buf, desc = "Explorer: volver al editor", silent = true })
    end,
  })

  -- Resize floating center on VimResized
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      local st = M.state.center
      if st and is_valid_win(st.win) then
        local cols = vim.o.columns
        local lines = vim.o.lines
        local width = math.floor(cols * 0.80)
        local height = math.floor(lines * 0.80)
        pcall(vim.api.nvim_win_set_config, st.win, {
          relative = "editor",
          row = math.floor((lines - height) / 2),
          col = math.floor((cols - width) / 2),
          width = width,
          height = height,
        })
      end
      -- Also resize right lateral width proportionally
      local rst = M.state.right
      if rst and is_valid_win(rst.win) then
        pcall(vim.api.nvim_win_set_width, rst.win, math.floor(vim.o.columns * 0.35))
      end
    end,
  })

  -- User commands for manual control
  vim.api.nvim_create_user_command("TerminalLeft", function()
    M.toggle_left()
  end, { desc = "Toggle terminal izquierda" })
  vim.api.nvim_create_user_command("TerminalCenter", function()
    M.toggle_center()
  end, { desc = "Toggle terminal flotante" })
  vim.api.nvim_create_user_command("TerminalRight", function()
    M.toggle_right()
  end, { desc = "Toggle terminal derecha" })
  vim.api.nvim_create_user_command("TerminalCloseAll", function()
    M.close_all()
  end, { desc = "Close all terminals" })
end

return M
