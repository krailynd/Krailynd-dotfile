-- Right-side terminal panel hosting the OpenCode TUI, plus minimal input UI.
local M = {}

M.state = nil
M._poll_timer = nil

local function is_valid_win(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
  return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

local function make_state(win, buf, chan, dir, session_id)
  return { win = win, buf = buf, chan = chan, dir = dir, session_id = session_id }
end

-- Strip editor furniture from the panel window so the TUI renders clean.
-- NOTE: a local statusline of "" resets to the global bar, so use a space.
-- winfixwidth: other splits (Space e, Space w, ...) must not rebalance and
-- shrink the panel back to equal width.
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
  vim.wo[win].winfixwidth = true
  if is_valid_buf(buf) then
    pcall(function()
      vim.bo[buf].syntax = ""
    end)
    vim.b[buf].minihipatterns_disable = true
    vim.b[buf].minicursorword_disable = true
    vim.b[buf].ts_highlight = false
    pcall(vim.treesitter.stop, buf)
  end
end

-- Buffer-local bindings shared by a freshly opened panel and an adopted
-- restored one: TermOpen hygiene re-apply, auto terminal-mode on WinEnter,
-- double-<Esc> back to the code window, and TermClose cleanup.
local function bind_terminal(buf, state)
  vim.b[buf].opencode_marker = true
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
      apply_hygiene(state.win, buf)
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
  vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n><C-w>p", {
    buffer = buf,
    desc = "OpenCode: leave terminal & return to code",
  })
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      if not is_valid_win(state.win) then
        M._cleanup(state)
      end
    end,
  })
end

local function opencode_cmd(dir, opts)
  local cmd = { "opencode", dir }
  if opts.session_id then
    cmd[#cmd + 1] = "-s"
    cmd[#cmd + 1] = opts.session_id
  end
  if opts.mini then
    cmd[#cmd + 1] = "--mini"
  end
  return cmd
end

-- Match a terminal buffer that belongs to OpenCode, by buffer name or marker.
-- Covers live panels, dead restored terminal buffers (buftype=terminal) and
-- the occasional session-restore artifact where the terminal name survives but
-- the buftype is empty.
local function is_opencode_term(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local is_term = vim.bo[buf].buftype == "terminal" or name:match("^term://")
  return is_term and (vim.b[buf].opencode_marker or name:match("opencode"))
end

-- Neovim has no jobstatus(); jobwait({chan}, 0) returns -1 while the job is
-- still running, or -3 once it has exited (or the channel is gone).
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

local function find_opencode_term()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_opencode_term(buf) then
      return buf
    end
  end
  return nil
end

-- Public accessor for the internal matcher: does a restored/live OpenCode
-- terminal buffer exist right now? Used to sweep restored zombies even when
-- auto_open is disabled (manual panel).
function M.has_opencode_term()
  return find_opencode_term() ~= nil
end

function M.set_poll_timer(handle)
  M._poll_timer = handle
end

function M.stop_poll()
  if M._poll_timer then
    pcall(vim.fn.timer_stop, M._poll_timer)
  end
  M._poll_timer = nil
end

function M.is_open()
  return M.state ~= nil and is_valid_win(M.state.win)
end

function M.get_state()
  return M.state
end

-- Clear module state, stop polling, and tear down the window/buffer. Safe to
-- call multiple times (e.g. once from termopen on_exit and once from close).
-- A per-state cleaning flag prevents re-entrancy: deleting the buffer kills
-- the terminal job, which fires TermClose, which would otherwise re-enter
-- _cleanup on the same buffer mid-deletion (E937).
function M._cleanup(state)
  if not state then
    return
  end
  if state.cleaning then
    return
  end
  state.cleaning = true
  if M.state == state then
    M.state = nil
  end
  M.stop_poll()
  if is_valid_win(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  if is_valid_buf(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
end

function M.open(dir, opts)
  opts = opts or {}
  if M.is_open() then
    if M.state.dir == dir then
      M.focus()
      return M.state
    end
    M.close()
  end

  vim.cmd("botright vertical new")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()
   -- NOTE: termopen() below sets buftype=terminal itself; setting it manually
  -- first raises E474 on some Neovim builds (vim.bo[buf].buftype="terminal").

  apply_hygiene(win, buf)

  local frac = opts.width or 0.35
  frac = math.max(opts.min_width or 0.20, math.min(opts.max_width or 0.80, frac))
  vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * frac))

  local state = make_state(win, buf, nil, dir, opts.session_id)
  local cmd = opencode_cmd(dir, opts)

  local ok, chan = pcall(vim.fn.termopen, cmd, {
    on_exit = function()
      M._cleanup(state)
    end,
  })
  if not ok or not chan or chan < 0 then
    M._cleanup(state)
    vim.notify("OpenCode: could not start the terminal", vim.log.levels.ERROR)
    return nil
  end
  state.chan = chan
  M.state = state

  bind_terminal(buf, state)

  -- When the panel opens it becomes the current window; enter terminal mode so
  -- it is immediately ready to type (matches the focus & type flow).
  if vim.api.nvim_get_current_win() == win then
    vim.cmd("startinsert")
  end

  return state
end

-- Adopt an OpenCode terminal that came back from a restored session.
-- A still-live buffer (rare) is adopted in place and its state returned. A DEAD
-- restored terminal cannot be resurrected (termopen refuses "Terminal already
-- connected"), so all such zombies are wiped and nil + wiped=true are returned:
-- the caller then opens a fresh panel, which lands on the same right edge.
function M.adopt_restored(dir, opts)
  opts = opts or {}
  if M.is_open() then
    return nil, false
  end
  local buf = find_opencode_term()
  if not buf then
    return nil, false
  end
  local chan = vim.b[buf].term_jobid
  if chan and job_running(chan) then
    local win = vim.fn.bufwinid(buf)
    if win < 0 then
      vim.cmd("botright vertical new")
      win = vim.api.nvim_get_current_win()
      pcall(vim.api.nvim_win_set_buf, win, buf)
    end
    apply_hygiene(win, buf)
    local frac = opts.width or 0.45
    frac = math.max(opts.min_width or 0.30, math.min(opts.max_width or 0.80, frac))
    vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * frac))
    local state = make_state(win, buf, chan, dir, opts.session_id)
    M.state = state
    bind_terminal(buf, state)
    return state, false
  end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if is_opencode_term(b) then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end
  return nil, true
end

function M.resize(delta_pct, opts)
  if not M.is_open() then
    return
  end
  opts = opts or {}
  local cols = vim.o.columns
  local old = vim.api.nvim_win_get_width(M.state.win)
  local new = old + (delta_pct or 0) * cols
  local min = math.floor((opts.min_width or 0.20) * cols)
  local max = math.floor((opts.max_width or 0.80) * cols)
  new = math.max(min, math.min(max, new))
  vim.api.nvim_win_set_width(M.state.win, math.floor(new))
end

function M.close()
  if M.state then
    M._cleanup(M.state)
  else
    M.stop_poll()
  end
end

function M.focus()
  if not M.is_open() then
    return
  end
  pcall(vim.api.nvim_set_current_win, M.state.win)
  pcall(vim.api.nvim_set_current_buf, M.state.buf)
end

-- Paste text into opencode's input without submitting, so the user can edit
-- it before sending. No trailing newline.
function M.send_text(text)
  if not M.state or not M.state.chan then
    return
  end
  pcall(vim.api.nvim_chan_send, M.state.chan, text)
end

function M.input(opts, on_submit)
  opts = opts or {}
  local ok = pcall(function()
    local snacks = require("snacks.input")
    snacks.prompt({
      prompt = opts.prompt,
      default = opts.default or "",
      icon = opts.icon or "󰒲",
      title = opts.title or "OpenCode",
      border = "rounded",
      relative = "editor",
      position = { row = "35%", col = "50%" },
      width = 64,
    }, on_submit)
  end)
  if not ok then
    vim.ui.input({ prompt = (opts.prompt or "") .. ": ", default = opts.default or "" }, on_submit)
  end
end

function M.confirm_yn(question, on_yes)
  local ok, res = pcall(vim.fn.confirm, question, "&Sí\n&No", 2)
  if ok and res == 1 then
    on_yes()
  end
end

return M