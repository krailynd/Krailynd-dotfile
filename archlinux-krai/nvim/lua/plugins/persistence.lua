-- Persistence: LazyVim already ships folke/persistence.nvim (keys: <leader>qs
-- restore, <leader>qS select, <leader>ql restore last, <leader>qd stop save).
-- We override two behaviors:
--   need = 0  -> ALWAYS save the session on exit, even when every file buffer
--                was closed with :q/:qa. Closing everything then coming back
--                must still restore the workspace (windows, dir, OpenCode).
--   terminal in sessionoptions -> terminal buffers (the OpenCode panel) are
--                persisted and restored so the panel comes back in place.
return {
  {
    "folke/persistence.nvim",
    opts = {
      need = 0,
    },
    config = function(_, opts)
      vim.opt.sessionoptions:append("terminal")
      require("persistence").setup(opts)
    end,
  },
}
