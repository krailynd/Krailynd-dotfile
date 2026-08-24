-- Free inline AI (ghost text) powered by Codeium/Windsurf.
-- Replaces the GitHub Copilot extra (see lua/config/lazy.lua) as the AI layer.
-- First run: :NeoCodeium auth  (needs internet + browser/token)
return {
  "monkoose/neocodeium",
  event = "VeryLazy",
  config = function()
    local neocodeium = require("neocodeium")
    neocodeium.setup({
      -- Hide AI suggestions while the blink.cmp menu is open
      filter = function()
        return not require("blink.cmp").is_visible()
      end,
    })

    -- Keymaps (Alt + key, adjust to taste)
    vim.keymap.set("i", "<A-f>", function() neocodeium.accept() end, { desc = "Accept AI suggestion" })
    vim.keymap.set("i", "<A-w>", function() neocodeium.accept_word() end, { desc = "Accept AI word" })
    vim.keymap.set("i", "<A-l>", function() neocodeium.accept_line() end, { desc = "Accept AI line" })
    vim.keymap.set("i", "<A-e>", function() neocodeium.cycle_or_complete() end, { desc = "Cycle AI suggestions" })
    vim.keymap.set("i", "<A-c>", function() neocodeium.clear() end, { desc = "Clear AI suggestion" })
  end,
}