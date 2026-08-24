return {
  -- Plugin: tiny-inline-diagnostic.nvim (Error Lens like VSCode)
  -- URL: https://github.com/rachartier/tiny-inline-diagnostic.nvim
  -- Shows diagnostics inline in buffer, VSCode Error Lens style.
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {
      preset = "modern",
      transparent_bg = false,
      transparent_cursorline = true,
      hi = {
        error = "DiagnosticError",
        warn = "DiagnosticWarn",
        info = "DiagnosticInfo",
        hint = "DiagnosticHint",
        arrow = "NonText",
        background = "CursorLine",
        mixing_color = "#06080f",
      },
      options = {
        show_source = {
          enabled = true,
          if_many = true,
        },
        show_code = true,
        use_icons_from_diagnostic = true,
        throttle = 0,
        softwrap = 30,
        multilines = {
          enabled = true,
          always_show = false,
        },
        show_all_diags_on_cursorline = false,
        overflow = {
          mode = "wrap",
          padding = 0,
        },
        break_line = {
          enabled = false,
          after = 30,
        },
        enable_on_insert = false,
        enable_on_select = false,
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      },
    },
    config = function(_, opts)
      require("tiny-inline-diagnostic").setup(opts)

      -- Professional diagnostic visuals: keep inline lens, disable virtual_text
      vim.diagnostic.config({
        virtual_text = false,
        virtual_lines = false,
        underline = true,
        severity_sort = true,
        update_in_insert = false,
        float = {
          border = "rounded",
          source = "if_many",
          header = "",
          prefix = "",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
        },
      })

      -- Solid background for centered float (Gentleman theme #06080f)
      -- Transparent theme sets NormalFloat to "none", so we define explicit hl
      vim.api.nvim_set_hl(0, "CenteredDiagnosticNormal", { bg = "#06080f", fg = "#F3F6F9" })
      vim.api.nvim_set_hl(0, "CenteredDiagnosticBorder", { bg = "#06080f", fg = "#7FB4CA" })
      vim.api.nvim_set_hl(0, "CenteredDiagnosticTitle", { bg = "#06080f", fg = "#E0C15A", bold = true })

      local severity_icons = {
        [vim.diagnostic.severity.ERROR] = "",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "",
      }
      local severity_names = {
        [vim.diagnostic.severity.ERROR] = "ERROR",
        [vim.diagnostic.severity.WARN] = "WARN",
        [vim.diagnostic.severity.INFO] = "INFO",
        [vim.diagnostic.severity.HINT] = "HINT",
      }
      local severity_hl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticError",
        [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticHint",
      }

      -- Wrap text to width using display width (handles unicode/icons)
      local function wrap_text(text, width)
        local result = {}
        local paragraphs = vim.split(text, "\n", { plain = true })
        for _, paragraph in ipairs(paragraphs) do
          if paragraph == "" then
            table.insert(result, "")
          else
            local words = {}
            for word in paragraph:gmatch("%S+") do
              table.insert(words, word)
            end
            local line = ""
            local line_width = 0
            for _, word in ipairs(words) do
              local w = vim.fn.strdisplaywidth(word)
              if w > width then
                if line ~= "" then
                  table.insert(result, line)
                  line = ""
                  line_width = 0
                end
                local start = 0
                local total = vim.fn.strchars(word)
                while start < total do
                  local chunk = vim.fn.strcharpart(word, start, width)
                  table.insert(result, chunk)
                  start = start + width
                end
              else
                if line == "" then
                  line = word
                  line_width = w
                elseif line_width + 1 + w <= width then
                  line = line .. " " .. word
                  line_width = line_width + 1 + w
                else
                  table.insert(result, line)
                  line = word
                  line_width = w
                end
              end
            end
            if line ~= "" then
              table.insert(result, line)
            end
          end
        end
        return result
      end

      -- Keep track of the centered float window to allow toggle/close
      local centered_win = nil
      local centered_buf = nil

      local function close_centered()
        if centered_win and vim.api.nvim_win_is_valid(centered_win) then
          vim.api.nvim_win_close(centered_win, true)
        end
        centered_win = nil
        if centered_buf and vim.api.nvim_buf_is_valid(centered_buf) then
          -- let bufhidden=wipe handle it, but clear ref
        end
        centered_buf = nil
      end

      local function show_centered_diagnostic()
        -- Toggle: if float is already open, handle intelligently
        if centered_win and vim.api.nvim_win_is_valid(centered_win) then
          -- If the float itself is focused, just close (pure toggle)
          if centered_buf and vim.api.nvim_get_current_buf() == centered_buf then
            close_centered()
            return
          end
          -- Otherwise (triggered from code buffer while old float lingers), close old and reopen
          close_centered()
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local lnum = cursor[1] - 1
        local col = cursor[2]
        local mode = vim.fn.mode()

        local diagnostics = {}
        -- Visual mode: collect diagnostics in selected range
        if mode == "v" or mode == "V" or mode == "\22" then
          local s_pos = vim.fn.getpos("'<")
          local e_pos = vim.fn.getpos("'>")
          local s_line = math.min(s_pos[2], e_pos[2]) - 1
          local e_line = math.max(s_pos[2], e_pos[2]) - 1
          for _, d in ipairs(vim.diagnostic.get(bufnr)) do
            if d.lnum >= s_line and d.lnum <= e_line then
              table.insert(diagnostics, d)
            end
          end
          -- Fallback to cursor line if selection has no diags
          if #diagnostics == 0 then
            diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })
          end
        else
          diagnostics = vim.diagnostic.get(bufnr, { lnum = lnum })
        end

        if #diagnostics == 0 then
          vim.notify("No hay diagnósticos en el cursor", vim.log.levels.INFO, { title = "Diagnóstico" })
          return
        end

        -- Prefer diagnostics under cursor column if multiple on line
        local under_cursor = {}
        for _, d in ipairs(diagnostics) do
          local s_col = d.col or 0
          local e_col = d.end_col or (s_col + 1)
          -- Handle diagnostics that span whole line (col 0)
          if col >= s_col and col < e_col then
            table.insert(under_cursor, d)
          end
        end
        local target = #under_cursor > 0 and under_cursor or diagnostics

        -- Layout constants
        local width = math.min(80, vim.o.columns - 10)
        if width < 50 then
          width = vim.o.columns - 4
        end
        local content_width = width - 4
        local display = {}
        local hl_regions = {} -- { line_idx, hl_group }

        -- Title header
        table.insert(display, "")
        table.insert(display, "  Diagnóstico  ")
        table.insert(display, "")

        for idx, diag in ipairs(target) do
          local icon = severity_icons[diag.severity] or "●"
          local sev_name = severity_names[diag.severity] or "UNKNOWN"
          local source = diag.source and ("  " .. diag.source) or ""
          local code = diag.code and ("  [" .. tostring(diag.code) .. "]") or ""
          local header = string.format("%s  %s%s%s", icon, sev_name, source, code)
          table.insert(display, header)
          -- track highlight for header line
          table.insert(hl_regions, { line = #display - 1, hl = severity_hl[diag.severity] or "DiagnosticError" })
          table.insert(display, string.rep("─", math.min(content_width, 36)))

          -- Message wrapped
          local msg = diag.message or ""
          local wrapped = wrap_text(msg, content_width)
          for _, l in ipairs(wrapped) do
            table.insert(display, l)
          end

          if idx < #target then
            table.insert(display, "")
            table.insert(display, string.rep("·", content_width))
            table.insert(display, "")
          end
        end

        table.insert(display, "")
        table.insert(display, string.rep("─", content_width))
        table.insert(display, "")
        table.insert(display, "💡 Cómo solucionarlo:")
        table.insert(display, "")

        -- Generic guidance + source-aware hint
        local has_code_action = false
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          if c.supports_method and c:supports_method("textDocument/codeAction") then
            has_code_action = true
            break
          end
        end
        -- Fallback: if any client supports codeAction, assume available
        if not has_code_action then
          -- Heuristic: if at least one LSP client attached, offer hint
          has_code_action = #vim.lsp.get_clients({ bufnr = bufnr }) > 0
        end

        local hints = {}
        if has_code_action then
          table.insert(hints, "• Presiona <leader>ca para ver correcciones automáticas (code actions).")
          table.insert(hints, "• También: :lua vim.lsp.buf.code_action()")
        else
          table.insert(hints, "• No hay LSP con code actions en este buffer; corrige manualmente.")
        end
        -- Source-specific tips
        local seen_source = {}
        for _, d in ipairs(target) do
          if d.source and not seen_source[d.source] then
            seen_source[d.source] = true
          end
        end
        for src, _ in pairs(seen_source) do
          if src:lower():find("eslint") then
            table.insert(hints, "• (" .. src .. ") Revisa la regla ESLint y ejecuta `eslint --fix` si aplica.")
          elseif src:lower():find("ts") or src:lower():find("typescript") then
            table.insert(hints, "• (" .. src .. ") Verifica tipos/imports; guarda para re-evaluar.")
          elseif src:lower():find("lua") then
            table.insert(hints, "• (" .. src .. ") Revisa sintaxis Lua / `stylua` y tipos `lua_ls`.")
          end
        end
        table.insert(hints, "• Navega entre errores con ]d / [d  y  ]e / [e  (siguiente/anterior).")
        table.insert(hints, "• Usa <leader>cd (LazyVim) para el float anclado a la línea.")
        table.insert(hints, "• Tras corregir, guarda el archivo para limpiar el diagnóstico.")

        for _, h in ipairs(wrap_text(table.concat(hints, "\n"), content_width)) do
          table.insert(display, h)
        end

        table.insert(display, "")

        -- Calculate height (capped to screen)
        local max_height = vim.o.lines - 6
        if max_height < 10 then
          max_height = vim.o.lines - 2
        end
        local height = math.min(#display, max_height)
        local row = math.floor((vim.o.lines - height) / 2)
        local col_pos = math.floor((vim.o.columns - width) / 2)
        if row < 0 then
          row = 0
        end
        if col_pos < 0 then
          col_pos = 0
        end

        -- Create buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].filetype = "markdown"
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, display)
        vim.bo[buf].modifiable = false
        vim.bo[buf].buftype = "nofile"

        -- Apply header highlights (severity icon + label)
        local ns = vim.api.nvim_create_namespace("CenteredDiagnosticHl")
        for _, r in ipairs(hl_regions) do
          pcall(vim.api.nvim_buf_add_highlight, buf, ns, r.hl, r.line, 0, -1)
        end
        -- Highlight the "💡 Cómo solucionarlo:" line
        for i, line in ipairs(display) do
          if line:find("Cómo solucionarlo") then
            pcall(vim.api.nvim_buf_add_highlight, buf, ns, "Title", i - 1, 0, -1)
          end
        end

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col_pos,
          style = "minimal",
          border = "rounded",
          title = " Diagnóstico ",
          title_pos = "center",
          footer = " q / Esc para cerrar  •  <leader>ca para fix ",
          footer_pos = "center",
          noautocmd = true,
        })

        centered_win = win
        centered_buf = buf

        -- Window options for readability
        vim.wo[win].wrap = false
        vim.wo[win].cursorline = false
        vim.wo[win].conceallevel = 0
        vim.api.nvim_win_set_option(win, "winhl", "Normal:CenteredDiagnosticNormal,FloatBorder:CenteredDiagnosticBorder,FloatTitle:CenteredDiagnosticTitle")

        -- Keymaps to close (q, Esc, Ctrl-c) and to trigger code_action
        local close_keys = { "q", "<Esc>", "<C-c>" }
        for _, k in ipairs(close_keys) do
          vim.keymap.set("n", k, close_centered, { buffer = buf, silent = true, nowait = true })
        end
        -- <leader>ca inside float: close and trigger code_action on original buffer
        vim.keymap.set("n", "<leader>ca", function()
          close_centered()
          vim.schedule(function()
            pcall(vim.lsp.buf.code_action)
          end)
        end, { buffer = buf, silent = true, desc = "Aplicar quick fix" })
        -- Also <CR> to trigger code_action
        vim.keymap.set("n", "<CR>", function()
          close_centered()
          vim.schedule(function()
            pcall(vim.lsp.buf.code_action)
          end)
        end, { buffer = buf, silent = true })

        -- Close on BufLeave or WinClosed outside
        vim.api.nvim_create_autocmd({ "BufLeave", "WinClosed" }, {
          buffer = buf,
          once = true,
          callback = function()
            close_centered()
          end,
        })
      end

      -- Expose globally and for which-key / command
      _G.show_centered_diagnostic = show_centered_diagnostic
      vim.api.nvim_create_user_command("DiagnosticExplain", show_centered_diagnostic, { desc = "Explicar diagnóstico centrado" })

      -- Keymaps: <leader>ce (main request) + gl alias, both in normal and visual
      vim.keymap.set({ "n", "v" }, "<leader>ce", show_centered_diagnostic, { desc = "Explicar error (centrado)", silent = true })
      vim.keymap.set({ "n", "v" }, "gl", show_centered_diagnostic, { desc = "Explicar diagnóstico (centrado)", silent = true })
    end,
  },
}
