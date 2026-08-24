-- This file contains the configuration for setting up the lazy.nvim plugin manager in Neovim.

-- Node.js configuration: prefer neovim npm CLI; never set to node binary itself
-- (setting to /usr/sbin/node causes `node /usr/sbin/node --version` health error).
-- The neovim npm package is installed via `npm install -g neovim` (brew/pacman).
local neovim_cli_candidates = {
  "/home/linuxbrew/.linuxbrew/lib/node_modules/neovim/bin/cli.js",
  "/home/linuxbrew/.linuxbrew/Cellar/node/26.7.0/lib/node_modules/neovim/bin/cli.js",
  "/usr/lib/node_modules/neovim/bin/cli.js",
  vim.fn.expand("~/.npm/lib/node_modules/neovim/bin/cli.js"),
}
for _, p in ipairs(neovim_cli_candidates) do
  if vim.fn.filereadable(p) == 1 then
    vim.g.node_host_prog = p
    break
  end
end
-- If no CLI found, leave unset so provider auto-detects via `npm root -g` (warns, not errors).
-- To silence the warning when you don't use Node remote plugins, uncomment:
-- vim.g.loaded_node_provider = 0

-- Spell-checking
vim.opt.spell = true -- activa spell checker
vim.opt.spelllang = { "en" }

-- Define the path to the lazy.nvim plugin
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if the lazy.nvim plugin is not already installed
if not vim.loop.fs_stat(lazypath) then
    -- Bootstrap lazy.nvim by cloning the repository
    -- stylua: ignore
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end

-- Prepend the lazy.nvim path to the runtime path
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- Fix copy and paste in WSL (Windows Subsystem for Linux)
vim.opt.clipboard = "unnamedplus" -- Use the system clipboard for all operations
if vim.fn.has("wsl") == 1 then
  -- win32yank.exe is the standard clipboard bridge for WSL. It lives in
  -- ~/.local/bin/win32yank.exe (installed from equalsraf/win32yank). Unlike
  -- clip.exe/powershell.exe it reliably handles Neovim's stdin/stdout pipes.
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf", -- Copy to the Windows system clipboard
      ["*"] = "win32yank.exe -i --crlf", -- Copy to the Windows system clipboard
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf", -- Paste from the Windows system clipboard
      ["*"] = "win32yank.exe -o --lf", -- Paste from the Windows system clipboard
    },
    cache_enabled = true,
  }
end

-- Setup lazy.nvim with the specified configuration
require("lazy").setup({
  spec = {
    -- Add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Import any extra modules here
    -- Editor plugins
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    { import = "lazyvim.plugins.extras.editor.mini-files" },
    -- { import = "lazyvim.plugins.extras.editor.snacks_explorer" },
    { import = "lazyvim.plugins.extras.editor.snacks_picker" },

    -- Debgugging plugins
    { import = "lazyvim.plugins.extras.dap.core" },

    -- Formatting plugins
    -- NOTE: this extra was renamed in newer LazyVim versions
    { import = "lazyvim.plugins.extras.lang.typescript.biome" },
    { import = "lazyvim.plugins.extras.formatting.prettier" },

    -- Linting plugins
    { import = "lazyvim.plugins.extras.linting.eslint" },

    -- Language support plugins
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.java" },

    -- Coding plugins
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.editor.mini-diff" },
    { import = "lazyvim.plugins.extras.coding.blink" },

    -- Utility plugins
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

    -- AI plugins
    -- GitHub Copilot inline extra disabled: replaced by neocodeium (free, no limits)
    -- as the AI ghost-text layer; see lua/plugins/neocodeium.lua. The copilot.lua
    -- plugin spec stays inert (optional = true, nothing requires it now).
    -- { import = "lazyvim.plugins.extras.ai.copilot" },

    -- Import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- Custom plugins are lazy-loaded by default now; every plugin in lua/plugins has
    -- an explicit event/cmd/keys trigger so nothing gets orphaned.
    lazy = true,
    -- It's recommended to leave version=false for now, since a lot of the plugins that support versioning
    -- have outdated releases, which may break your Neovim install.
    version = false, -- Always use the latest git commit
    -- version = "*", -- Try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "gentleman-kanagawa-blur", "kanagawa", "habamax" } }, -- Colorschemes used by this config
  checker = { enabled = false }, -- Check updates manually with :Lazy update (avoids background git checks)
  performance = {
    cache = {
      -- Cache the processed plugin specs across sessions so startup skips
      -- re-processing them every time. Pure speed: no visual or behavior
      -- change. First startup after enabling regenerates the cache.
      enabled = true,
    },
    rtp = {
      -- Disable some runtime path plugins to improve performance
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
