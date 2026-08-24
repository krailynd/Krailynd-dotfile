return {
  "Gentleman-Programming/veil.nvim",
  event = "VeryLazy", -- keeps auto-enable working without blocking startup
  config = function()
    require("veil").setup()
  end,
}
