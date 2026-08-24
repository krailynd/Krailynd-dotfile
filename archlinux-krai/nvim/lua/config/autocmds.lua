-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Preserve terminal buffers (the OpenCode panel) in saved sessions so they are
-- restored as (dead) terminal windows that the opencode plugin re-adopts.
vim.opt.sessionoptions:append("terminal")

-- NOTE: the session auto-restore on startup lives in init.lua, registered on
-- VimEnter BEFORE this file loads (autocmds.lua loads on VeryLazy, after
-- VimEnter has already fired). It must run before the OpenCode plugin's
-- VeryLazy auto-open so the restored panel terminal can be adopted, not
-- duplicated.

-- The dashboard (opened via <leader>D) is a floating snacks_dashboard buffer.
-- which-key's automatic space trigger does not survive there, so <Space>
-- (leader) appears dead inside the dashboard. Register a stable buffer-local
-- space mapping that always opens the which-key leader menu.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_dashboard",
  callback = function()
    vim.keymap.set("n", " ", function()
      require("which-key.state").start({ keys = " " })
    end, { buffer = true, nowait = true, desc = "dashboard leader menu" })
  end,
})
