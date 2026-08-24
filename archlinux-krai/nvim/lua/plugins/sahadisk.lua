-- SahaDisk integration: opens the SahaDisk TUI in a centered floating window.
-- Prefix: <leader>k  (group defined in lua/plugins/which-key.lua)
return {
  dir = vim.fn.stdpath("config") .. "/lua/sahadisk",
  name = "sahadisk-nvim",
  lazy = true,
  keys = {
    { "<leader>ko", desc = "Open SahaDisk TUI" },
    { "<leader>kd", desc = "Doctor: diagnostics" },
    { "<leader>kc", desc = "Cleanup engine" },
    { "<leader>kk", desc = "Docker management" },
    { "<leader>kq", desc = "Quick dashboard" },
  },
  config = function()
    local sahadisk = require("sahadisk")
    sahadisk.setup()
  end,
}
