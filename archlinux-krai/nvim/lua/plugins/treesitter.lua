return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Ensure required parsers are installed (fixes health warnings)
      -- LazyVim's java extra already adds "java"; we extend with missing langs.
      local ensure = opts.ensure_installed or {}
      vim.list_extend(ensure, {
        "css",
        "latex",
        "norg",
        "scss",
        "svelte",
        "typst",
        "vue",
        "markdown",
        "markdown_inline",
        "html",
        "yaml",
        "json",
        "lua",
        "python",
        "bash",
        "javascript",
        "typescript",
        "java",
      })
      -- Deduplicate
      local seen = {}
      local deduped = {}
      for _, v in ipairs(ensure) do
        if not seen[v] then
          seen[v] = true
          table.insert(deduped, v)
        end
      end
      opts.ensure_installed = deduped
    end,
  },
}
