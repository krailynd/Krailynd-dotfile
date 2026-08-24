-- Plugin: vim-visual-multi (VM) - multicursor editing
-- URL: https://github.com/mg979/vim-visual-multi
-- Defaults (no conflicts with existing keymaps):
--   <C-n>       - select word / add cursor
--   <C-Up>      - add cursor above
--   <C-Down>    - add cursor below
--   <C-x>       - skip next occurrence
--   q           - skip (in VM select mode)
--   <Esc>       - exit multicursor mode
return {
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
  },
}