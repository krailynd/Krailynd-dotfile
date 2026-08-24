-- Triple toggleable terminals (left-bottom, floating center, right lateral)
-- Lightweight native termopen + window management (no toggleterm dependency).
-- Uses same hygiene / Esc Esc / WinEnter patterns as opencode & sahadisk.
return {
  dir = vim.fn.stdpath("config") .. "/lua/terminal",
  name = "terminal-triple",
  lazy = true,
  event = "VeryLazy",
  keys = {
    { "<leader>pl", desc = "Terminal izquierda (abajo explorer)" },
    { "<leader>pc", desc = "Terminal flotante (centro)" },
    { "<leader>pr", desc = "Terminal derecha" },
    { "<leader>pe", desc = "Ir al explorador (foco)" },
    { "<leader>pt", desc = "Ir a la terminal (última activa)" },
  },
  config = function()
    require("terminal").setup({
      keymaps = {
        left = "<leader>pl",
        center = "<leader>pc",
        right = "<leader>pr",
      },
    })
  end,
}
