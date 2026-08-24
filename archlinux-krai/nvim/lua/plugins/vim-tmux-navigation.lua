return {
  -- Plugin: nvim-tmux-navigation
  -- URL: https://github.com/alexghergh/nvim-tmux-navigation
  -- Description: A Neovim plugin that allows seamless navigation between Neovim and tmux panes.
  "alexghergh/nvim-tmux-navigation",
  event = "VeryLazy", -- lazy-load instead of loading at startup
  config = function()
    local nav = require("nvim-tmux-navigation")
    vim.keymap.set("n", "<C-h>", nav.NvimTmuxNavigateLeft) -- Navigate to the left pane
    vim.keymap.set("n", "<C-j>", nav.NvimTmuxNavigateDown) -- Navigate to the bottom pane
    vim.keymap.set("n", "<C-k>", nav.NvimTmuxNavigateUp) -- Navigate to the top pane
    vim.keymap.set("n", "<C-l>", nav.NvimTmuxNavigateRight) -- Navigate to the right pane
    vim.keymap.set("n", "<C-\\>", nav.NvimTmuxNavigateLastActive) -- Navigate to the last active pane
    vim.keymap.set("n", "<C-Space>", nav.NvimTmuxNavigateNext) -- Navigate to the next pane
  end,
}