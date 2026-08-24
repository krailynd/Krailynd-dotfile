-- Session lookup and per-project state/log for the OpenCode integration.
local M = {}

local DB_PATH = vim.fn.expand("~/.local/share/opencode/opencode.db")
local HISTORY_CAP = 50
local LIST_LIMIT = 50

local function state_dir()
  local base = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
  return base .. "/opencode-nvim"
end

local function epoch_ms()
  return os.time() * 1000
end

local function sql_escape(s)
  return (s:gsub("'", "''"))
end

-- Directory variants used to match the session table: the normalized path
-- plus its trailing-slash-free form. opencode records the cwd it was
-- launched from, which may or may not carry a trailing slash.
local function dir_variants(dir)
  local d = vim.fs.normalize(dir)
  local stripped = d == "/" and d or (d:gsub("/+$", ""))
  if d == stripped then
    return { d }
  end
  return { d, stripped }
end

function M.ensure_db()
  if vim.fn.executable("opencode") ~= 1 then
    return false
  end
  if vim.fn.filereadable(DB_PATH) ~= 1 then
    return false
  end
  return true
end

function M.list_sessions(dir)
  if not M.ensure_db() then
    return {}
  end
  local conds = {}
  for _, v in ipairs(dir_variants(dir)) do
    conds[#conds + 1] = "directory = '" .. sql_escape(v) .. "'"
  end
  local where = table.concat(conds, " OR ")
  local sql = "SELECT id, title FROM session WHERE ("
    .. where
    .. ") AND (time_archived IS NULL OR time_archived = 0)"
    .. " ORDER BY time_updated DESC LIMIT "
    .. LIST_LIMIT

  -- Fast path: sqlite3 CLI reads the DB directly (~ms, no Node process).
  -- Fallback: `opencode db` spawns the CLI (slow, ~1 Node boot per call).
  local rows = nil
  if vim.fn.executable("sqlite3") == 1 then
    rows = M._query_sqlite3(sql)
  end
  if rows == nil then
    rows = M._query_opencode(sql)
  end

  local out = {}
  if type(rows) == "table" then
    for _, row in ipairs(rows) do
      if type(row) == "table" and row.id then
        out[#out + 1] = { id = row.id, title = row.title or "" }
      end
    end
  end
  return out
end

function M._query_sqlite3(sql)
  local ok, handle = pcall(vim.system, { "sqlite3", "-json", DB_PATH, sql }, { text = true })
  if not ok then
    return nil
  end
  local okw, res = pcall(function()
    return handle:wait(5000)
  end)
  if not okw or res.code ~= 0 or not res.stdout or res.stdout == "" then
    return nil
  end
  local okd, decoded = pcall(vim.json.decode, res.stdout)
  if not okd or type(decoded) ~= "table" then
    return nil
  end
  return decoded
end

function M._query_opencode(sql)
  local ok, handle = pcall(vim.system, { "opencode", "db", sql, "--format", "json" }, { text = true })
  if not ok then
    return nil
  end
  local okw, res = pcall(function()
    return handle:wait(15000)
  end)
  if not okw or res.code ~= 0 or not res.stdout or res.stdout == "" then
    return nil
  end
  local okd, decoded = pcall(vim.json.decode, res.stdout)
  if not okd or type(decoded) ~= "table" then
    return nil
  end
  return decoded
end

function M.get_latest(dir)
  return M.list_sessions(dir)[1] or nil
end

function M.state_path(dir)
  local key = vim.fn.sha256(vim.fs.normalize(dir)):sub(1, 12)
  return state_dir() .. "/" .. key .. ".json"
end

function M.load_state(dir)
  local path = M.state_path(dir)
  local ok, data = pcall(function()
    local f = io.open(path, "r")
    if not f then
      return {}
    end
    local content = f:read("*a")
    f:close()
    local t = vim.json.decode(content)
    if type(t) ~= "table" then
      return {}
    end
    if type(t.history) ~= "table" then
      t.history = {}
    end
    return t
  end)
  if not ok then
    return {}
  end
  return data
end

function M.remember(dir, id, title, reason)
  local st = M.load_state(dir)
  st.project = vim.fs.normalize(dir)
  st.last_session_id = id
  st.last_title = title or ""
  st.updated_at = epoch_ms()
  local entry = { id = id, title = title or "", at = epoch_ms(), reason = reason or "" }
  local history = {}
  for _, h in ipairs(st.history or {}) do
    if h and h.id ~= id then
      history[#history + 1] = h
    end
  end
  table.insert(history, 1, entry)
  while #history > HISTORY_CAP do
    table.remove(history)
  end
  st.history = history

  local okdir = pcall(vim.fn.mkdir, state_dir(), "p")
  if not okdir then
    return false
  end
  local path = M.state_path(dir)
  local tmp = path .. ".tmp"
  local okw = pcall(function()
    local f = io.open(tmp, "w")
    if not f then
      error("cannot open temp state file")
    end
    f:write(vim.json.encode(st))
    f:close()
  end)
  if not okw then
    return false
  end
  pcall(vim.uv.fs_rename, tmp, path)
  return true
end

function M.forget(dir)
  local path = M.state_path(dir)
  pcall(vim.uv.fs_unlink, path)
  pcall(vim.uv.fs_unlink, path .. ".tmp")
end

return M