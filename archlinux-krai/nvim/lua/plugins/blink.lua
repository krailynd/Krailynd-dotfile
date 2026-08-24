return {
  "saghen/blink.cmp",
  lazy = true,
  -- NOTE: avante sources removed — avante.nvim is disabled (see lua/plugins/disabled.lua).
  -- Leaving them here would make blink.cmp try to load avante's compat providers
  -- and shadow the real LSP/path/buffer sources configured by LazyVim.
  --
  -- Adapted from the "2026 ultimate stack" guide for LazyVim:
  -- LazyVim's blink extra already provides sources (lsp/path/snippets/buffer),
  -- snippets via friendly-snippets, and the Tab wiring. We only add the guide's
  -- tuning. blink's own ghost text stays OFF: neocodeium owns the AI ghost text
  -- (see lua/plugins/neocodeium.lua). Enabling both causes visual conflicts.
  opts = {
    -- Tab: accept neocodeium ghost text first, then super-tab behavior
    -- (snippet-aware select_and_accept), then literal tab. This is the exact
    -- super-tab <Tab> chain with the AI ghost-text acceptance prepended.
    keymap = {
      preset = "super-tab", -- Tab/Shift-Tab cycle, Enter accepts (VSCode-style)
      -- IntelliJ-like manual triggers: Ctrl+Space = Basic Completion, Ctrl+K = Parameter Info
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      ["<Tab>"] = {
        function(cmp)
          local nc = require("neocodeium")
          if nc.visible() then
            nc.accept() -- accept the AI ghost text
            return true -- consume the key, stop blink's chain
          end
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        "snippet_forward",
        "fallback",
      },
    },
    appearance = {
      nerd_font_variant = "mono",
      use_nvim_cmp_as_default = true, -- fallback highlight groups to nvim-cmp
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text = { enabled = false }, -- neocodeium owns ghost text
      menu = {
        auto_show = true,
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind", gap = 1 },
          },
        },
      },
    },
    sources = {
      -- Prioritize LSP over the rest (guide's scoring). LSP fallbacks = {} ensures
      -- buffer completions show ALONGSIDE LSP (not only when LSP returns 0 items),
      -- so everyday words remain available while jdtls is still indexing.
      providers = {
        lsp = { score_offset = 4, fallbacks = {} },
        path = { score_offset = 3 },
        snippets = { score_offset = 2 },
        buffer = { score_offset = 1 },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
    signature = { enabled = true, window = { show_documentation = true } }, -- inline Parameter Info like IntelliJ Ctrl+P
  },
}
