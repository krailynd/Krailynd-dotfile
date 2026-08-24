-- Ensure a writable runtime directory exists before anything else.
-- Fixes `serverstart()` failures (e.g. fzf-lua) when XDG_RUNTIME_DIR points
-- to a missing /run/user/<uid> (common on non-systemd sessions, WSL, etc.)
local run_dir = vim.fn.stdpath("run")
if vim.fn.isdirectory(run_dir) == 0 or vim.fn.filewritable(run_dir) ~= 2 then
  local fallback = vim.fn.stdpath("state") .. "/run"
  vim.fn.mkdir(fallback, "p", tonumber("700", 8))
  vim.env.XDG_RUNTIME_DIR = fallback
end

-- Configure Node.js before loading plugins
require("config.nodejs").setup({ silent = true })

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Auto-restore the persisted workspace when starting Neovim in a directory
-- that has a saved session. Registered here (not in config/autocmds.lua) so it
-- fires on VimEnter BEFORE the OpenCode plugin's VeryLazy auto-open: the
-- restored (dead) panel terminal is adopted in place instead of duplicated.
-- Only loads when starting WITHOUT file arguments (plain `nvim` or `nvim .`);
-- opening a specific file must not clobber it. Skipped in headless runs.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then
      return
    end
    for i = 1, vim.fn.argc() do
      if vim.fn.isdirectory(vim.fn.argv(i - 1)) == 0 then
        return
      end
    end
    vim.schedule(function()
      pcall(function()
        require("persistence").load()
      end)
    end)
  end,
})

-- Leave timeoutlen to which-key's init (300ms) so the leader key feels snappy.
-- ttimeoutlen = 0 disables the delay when leaving insert mode.
vim.opt.ttimeoutlen = 0