return {
  "jonroosevelt/gemini-cli.nvim",
  event = "VeryLazy", -- lazy-load: AI plugin, not needed at startup
  config = function()
    require("gemini").setup()
  end,
}
