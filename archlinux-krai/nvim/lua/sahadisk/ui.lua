-- Centered floating terminal window hosting the SahaDisk TUI.
-- Mirrors the opencode panel pattern, but floats in the middle of the
-- editor instead of docking to a side.
local M = {}

M.state = nil

local function is_valid_win(win)
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

local function is_valid_buf(buf)
  return buf ~= nil and vim.api.nvim_buf_is_valid(buf)
end

local function make_state(win, buf, chan, cmd)
  return { win = win, buf = buf, chan = chan, cmd = cmd }
end

-- Strip editor furniture from the floating window so the TUI renders clean.
-- NOTE: a local statusline of "" resets to the global bar, so use a space.
local function apply_hygiene(win)
  if not is_valid_win(win) then
    return
  end
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].list = false
  vim.wo[win].cursorline = false
  vim.wo[win].cursorcolumn = false
  vim.wo[win].winbar = " "
  vim.wo[win].statusline = " "
end

-- Terminal-mode bindings shared by every fresh float: auto terminal-mode on
-- WinEnter, double-<Esc> back to the previous code window, and TermClose
-- cleanup.
local function bind_terminal(buf, state)
  vim.b[buf].sahadisk_marker = true
  vim.api.nvim_create_autocmd("TermOpen", {
    buffer = buf,
    once = true,
    callback = function()
      apply_hygiene(state.win)
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
    desc = "SahaDisk: leave terminal & return to code",
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

  -- OSC 51 drop handler: when SahaDisk sends ESC ] 51 ; ["drop","path"] ST,
  -- open the file in the code window (not the floating terminal).
  vim.api.nvim_create_autocmd("TermRequest", {
    buffer = buf,
    callback = function()
      local seq = vim.v.termrequest or ""
      -- OSC 51: \x1b]51;["drop","/path"]\x1b\\  or  \x07
      if seq:sub(1, 5) == "\x1b]51;" then
        local json_str = seq:sub(6):gsub("[\x07\x1b].*", "")
        local ok, data = pcall(vim.json.decode, json_str)
        if ok and type(data) == "table" and data[1] == "drop" and data[2] then
          vim.schedule(function()
            -- Switch to the previous (code) window, then open the file
            vim.cmd("wincmd p")
            vim.cmd("drop " .. vim.fn.fnameescape(data[2]))
          end)
        end
      end
    end,
  })
end

-- Match a SahaDisk terminal buffer by name or marker.
local function is_sahadisk_term(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local is_term = vim.bo[buf].buftype == "terminal" or name:match("^term://")
  return is_term and (vim.b[buf].sahadisk_marker or name:match("sahadisk"))
end

local function find_sahadisk_term()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_sahadisk_term(buf) then
      return buf
    end
  end
  return nil
end

function M.is_open()
  return M.state ~= nil and is_valid_win(M.state.win)
end

function M.get_state()
  return M.state
end

-- Safe to call multiple times (termopen on_exit + close). A per-state flag
-- prevents re-entrancy: deleting the buffer kills the job, which fires
-- TermClose, which would otherwise re-enter mid-deletion (E937).
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
  if is_valid_win(state.win) then
    pcall(vim.api.nvim_win_close, state.win, true)
  end
  if is_valid_buf(state.buf) then
    pcall(vim.api.nvim_buf_delete, state.buf, { force = true })
  end
end

-- Open SahaDisk (with optional subcommand and args) in a centered floating
-- terminal window sized as a fraction of the editor.
function M.open(opts)
  opts = opts or {}
  if M.is_open() then
    M.focus()
    return M.state
  end

  local cols = vim.o.columns
  local lines = vim.o.lines
  local width = math.floor(cols * (opts.width or 0.90))
  local height = math.floor(lines * (opts.height or 0.88))

  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((lines - height) / 2),
    col = math.floor((cols - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = opts.border or "rounded",
    title = opts.title or " SahaDisk ",
    title_pos = "center",
    zindex = 50,
  })

  apply_hygiene(win)

  local cmd = { "SahaDisk" }
  if opts.args then
    for _, a in ipairs(opts.args) do
      cmd[#cmd + 1] = a
    end
  end
  if opts.dir then
    cmd[#cmd + 1] = opts.dir
  end

  local state = make_state(win, buf, nil, cmd)

  -- Ensure a server socket exists so SahaDisk can hand paths back to this
  -- Nvim instance via OSC 51 (see TermRequest handler above).
  local nvim_sock = vim.v.servername
  if nvim_sock == "" then
    nvim_sock = vim.fn.serverstart()
  end

  local ok, chan = pcall(vim.fn.termopen, cmd, {
    env = { NVIM = nvim_sock },
    on_exit = function()
      M._cleanup(state)
    end,
  })
  if not ok or not chan or chan < 0 then
    M._cleanup(state)
    vim.notify("SahaDisk: could not start the terminal", vim.log.levels.ERROR)
    return nil
  end
  state.chan = chan
  M.state = state

  bind_terminal(buf, state)

  -- The float is the current window; enter terminal mode immediately so the
  -- TUI is ready to use.
  if vim.api.nvim_get_current_win() == win then
    vim.cmd("startinsert")
  end

  return state
end

function M.close()
  if M.state then
    M._cleanup(M.state)
  end
end

-- Toggle: close if the float is focused, otherwise open (or focus) it.
function M.toggle(opts)
  if M.is_open() then
    if vim.api.nvim_get_current_win() == M.state.win then
      M.close()
    else
      M.focus()
    end
    return
  end
  M.open(opts)
end

function M.focus()
  if not M.is_open() then
    return
  end
  pcall(vim.api.nvim_set_current_win, M.state.win)
  pcall(vim.api.nvim_set_current_buf, M.state.buf)
end

return M
