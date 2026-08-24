return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/opencode",
    name = "opencode-nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {
      -- defaults are in init.lua; user can override here
    },
    config = function(_, opts)
      require("opencode").setup(opts)
    end,
  },
}