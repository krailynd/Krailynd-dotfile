-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Python host: use Arch system python (has pynvim via pacman). Avoid Windows python from PATH.
vim.g.python3_host_prog = "/usr/bin/python3"
-- Perl/Ruby providers are optional; silence if you don't use them:
-- vim.g.loaded_perl_provider = 0
-- vim.g.loaded_ruby_provider = 0
-- Node provider now uses neovim npm CLI (see lua/config/lazy.lua); leave unset to auto-detect if missing.
