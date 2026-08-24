local mode = {
  "mode",
  fmt = function(s)
    local mode_map = {
      ["NORMAL"] = "N",
      ["O-PENDING"] = "N?",
      ["INSERT"] = "I",
      ["VISUAL"] = "V",
      ["V-BLOCK"] = "VB",
      ["V-LINE"] = "VL",
      ["V-REPLACE"] = "VR",
      ["REPLACE"] = "R",
      ["COMMAND"] = "!",
      ["SHELL"] = "SH",
      ["TERMINAL"] = "T",
      ["EX"] = "X",
      ["S-BLOCK"] = "SB",
      ["S-LINE"] = "SL",
      ["SELECT"] = "S",
      ["CONFIRM"] = "Y?",
      ["MORE"] = "M",
    }
    return mode_map[s] or s
  end,
}

local function codecompanion_adapter_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end

  return " " .. chat.adapter.formatted_name
end

local function codecompanion_current_model_name()
  local chat = require("codecompanion").buf_get_chat(vim.api.nvim_get_current_buf())
  if not chat then
    return nil
  end

  return chat.settings.model
end
-- This file contains the configuration for various UI-related plugins in Neovim.
return {
  -- Plugin: folke/todo-comments.nvim
  -- URL: https://github.com/folke/todo-comments.nvim
  -- Description: Plugin to highlight and search for TODO, FIX, HACK, etc. comments in your code.
  -- IMPORTANT: using version "*" to fix a bug
  { "folke/todo-comments.nvim", version = "*" },

  -- Plugin: folke/which-key.nvim
  -- URL: https://github.com/folke/which-key.nvim
  -- Description: Plugin to show a popup with available keybindings.
  -- IMPORTANT: using event "VeryLazy" to optimize loading time
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "classic",
      win = { border = "single" },
    },
  },

  -- Plugin: nvim-docs-view
  -- URL: https://github.com/amrbashir/nvim-docs-view
  -- Description: A Neovim plugin for viewing documentation.
  {
    "amrbashir/nvim-docs-view",
    lazy = true, -- Load this plugin lazily
    cmd = "DocsViewToggle", -- Command to toggle the documentation view
    opts = {
      position = "right", -- Position the documentation view on the right
      width = 60, -- Set the width of the documentation view
    },
  },

  -- Plugin: lualine.nvim
  -- URL: https://github.com/nvim-lualine/lualine.nvim
  -- Description: A blazing fast and easy to configure Neovim statusline plugin.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy", -- Load this plugin on the 'VeryLazy' event
    requires = { "nvim-tree/nvim-web-devicons", opt = true }, -- Optional dependency for icons
    opts = {
      options = {
        theme = "gentleman-kanagawa-blur", -- Set the theme for lualine
        icons_enabled = true, -- Enable icons in the statusline
      },
      sections = {
        lualine_a = {
          {
            "mode", -- Display the current mode
            icon = "󱗞", -- Set the icon for the mode
          },
        },
      },
      extensions = {
        "quickfix",
        {
          filetypes = { "oil" },
          sections = {
            lualine_a = {
              mode,
            },
            lualine_b = {
              function()
                local ok, oil = pcall(require, "oil")
                if not ok then
                  return ""
                end

                ---@diagnostic disable-next-line: param-type-mismatch
                local path = vim.fn.fnamemodify(oil.get_current_dir(), ":~")
                return path .. " %m"
              end,
            },
          },
        },
        {
          filetypes = { "codecompanion" },
          sections = {
            lualine_a = {
              mode,
            },
            lualine_b = {
              codecompanion_adapter_name,
            },
            lualine_c = {
              codecompanion_current_model_name,
            },
            lualine_x = {},
            lualine_y = {
              "progress",
            },
            lualine_z = {
              "location",
            },
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {
              codecompanion_adapter_name,
            },
            lualine_c = {},
            lualine_x = {},
            lualine_y = {
              "progress",
            },
            lualine_z = {},
          },
        },
      },
    },
  },

  -- Plugin: incline.nvim
  -- URL: https://github.com/b0o/incline.nvim
  -- Description: A Neovim plugin for showing the current filename in a floating window.
  {
    "b0o/incline.nvim",
    event = "BufReadPre", -- Load this plugin before reading a buffer
    priority = 1200, -- Set the priority for loading this plugin
    config = function()
      require("incline").setup({
        window = { margin = { vertical = 0, horizontal = 1 } }, -- Set the window margin
        hide = {
          cursorline = true, -- Hide the incline window when the cursorline is active
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t") -- Get the filename
          if vim.bo[props.buf].modified then
            filename = "[+] " .. filename -- Indicate if the file is modified
          end

          local icon, color = require("nvim-web-devicons").get_icon_color(filename) -- Get the icon and color for the file
          return { { icon, guifg = color }, { " " }, { filename } } -- Return the rendered content
        end,
      })
    end,
  },

  -- Plugin: zen-mode.nvim
  -- URL: https://github.com/folke/zen-mode.nvim
  -- Description: A Neovim plugin for distraction-free coding.
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode", -- Command to toggle Zen Mode
    opts = {
      plugins = {
        gitsigns = true, -- Enable gitsigns integration
        tmux = true, -- Enable tmux integration
        kitty = { enabled = false, font = "+2" }, -- Disable kitty integration and set font size
        twilight = { enabled = true }, -- Enable twilight integration
      },
    },
    keys = { { "<leader>z", "<cmd>ZenMode<cr>", desc = "Zen Mode" } }, -- Keybinding to toggle Zen Mode
  },

  -- Plugin: snacks.nvim
  -- URL: https://github.com/folke/snacks.nvim/tree/main
  -- Description: A Neovim plugin for creating a customizable dashboard.
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find Buffers",
      },
    },
    opts = {
      notifier = {},
      image = {
        enabled = true,
        doc = {
          enabled = true,
          -- Conservative caps so image rendering never stalls the UI.
          max_width = 100,
          max_height = 100,
        },
        -- Resolve Obsidian wikilinks (![[file.png|342]]) to the vault
        -- attachment folder. `|342` (display width) is stripped here as a
        -- fallback in case the treesitter query did not remove it already.
        -- Returning nil falls back to snacks' default resolution.
        resolve = function(file, src)
          src = src:gsub("|.*$", "")
          if src:find("^%a+://") then
            return nil
          end
          local dir = vim.fn.fnamemodify(file, ":h")
          for _, c in ipairs({
            dir .. "/" .. src,
            "/mnt/e/YOUR_VAULT/Media/" .. src,
            "/mnt/e/YOUR_VAULT/" .. src,
          }) do
            if vim.fn.filereadable(c) == 1 then
              return c
            end
          end
          return nil
        end,
      },
      picker = {
        exclude = {
          ".git",
          "node_modules",
        },
        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          filename_bonus = true,
        },
        sources = {
          -- explorer = {
          --   matcher = {
          --     fuzzy = true, -- Enables fuzzy matching, so you can be a bit imprecise with your search terms
          --     smartcase = true, -- If your search term has uppercase letters, the search becomes case-sensitive
          --     ignorecase = true, -- Ignores case when searching, unless smartcase is triggered
          --     filename_bonus = true, -- Gives a higher priority to matches in filenames
          --     sort_empty = false, -- If no matches are found, it won't sort the results
          --   },
          -- },
        },
      },
      dashboard = {
        -- Two-column layout: the menu (keys, files, projects) on the LEFT
        -- pane, the ASCII header art on the RIGHT pane. On narrow terminals
        -- (< ~132 cols) it gracefully falls back to one centered column.
        width = 64,
        sections = {
          { section = "header", pane = 2 },
          { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1, pane = 1 },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, pane = 1 },
          { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1, pane = 1 },
          { section = "startup", pane = 1 },
        },
        preset = {
          header = [[
⠀⠀⠀⠀⠀⣠⡶⠛⠛⠋⠛⠓⠲⣄⡀⠀⠀⠀⠀⠀
⠀⠀⠀⡀⡼⠇⠈⠀⠀⠀⠀⠀⠀⠈⣿⡆⠀⠀⠀⠀
⡄⠀⠀⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀
⣿⡀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡇⠀⠀⠀⠀
⣿⡇⠀⠀⠙⢦⣄⡀⠀⠀⠀⠀⣠⣪⡿⠀⠀⠀⠀⠀
⠹⣧⠀⠀⠀⠀⠈⠛⠭⠭⠽⣽⣿⣿⣄⠀⠀⠀⠀⠀
⠀⠹⣧⡄⠀⠀⠀⠀⢀⣀⣾⣵⣟⡻⣿⣝⣆⠀⠀⠀
⠀⠀⠹⢿⣶⣴⣥⣷⣿⣟⠟⠀⣷⡃⠉⢻⣻⣄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡇⠀⠀⠈⣽⡆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⡇⠀⠀⠀⠙⣿⡆
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣯⡇⠀⠀⠀⠀⣟⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡿⡇⠀⠀⠀⠀⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣷⡇⠀⠀⠀⠀⣿⡇
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⡁⠀⠀⠀⠀⢿⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⢿⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡿⠈⣿⡇⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡃⠀⠹⣿⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠄⠀⠀⢻⡿⣀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢼⣿⠰⠀⠀⠀⢻⡼⣆⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡿⠀⠀⠀⠀⠀⠹⣿⣆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠙⢿⡗
]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "ff", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    },
  },
}
