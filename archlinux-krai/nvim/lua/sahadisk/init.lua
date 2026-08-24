-- SahaDisk integration for LazyVim: opens the SahaDisk TUI (file manager /
-- disk-usage analyzer) in a centered floating terminal window, plus quick
-- subcommand shortcuts (doctor, scan, docker, cleanup, quick dashboard).
-- Prefix: <leader>k  (free in this config — see lua/plugins/which-key.lua)
local ui = require("sahadisk.ui")

local M = {}

local PREFIX = "k"

-- Quick open of a subcommand: close any current float, then open the new one.
local function open_cmd(subcmd, opts)
  opts = opts or {}
  if ui.is_open() then
    ui.close()
  end
  local args = subcmd ~= nil and { subcmd } or nil
  ui.open({
    args = args,
    title = opts.title or (" SahaDisk " .. (subcmd or "")) .. " ",
  })
end

function M.setup()
  vim.keymap.set("n", "<leader>" .. PREFIX .. "o", M.open_default, {
    desc = "Open SahaDisk TUI",
  })
  vim.keymap.set("n", "<leader>" .. PREFIX .. "d", M.open_doctor, {
    desc = "Doctor: diagnostics",
  })
  vim.keymap.set("n", "<leader>" .. PREFIX .. "c", M.open_cleanup, {
    desc = "Cleanup engine",
  })
  vim.keymap.set("n", "<leader>" .. PREFIX .. "k", M.open_docker, {
    desc = "Docker management",
  })
  vim.keymap.set("n", "<leader>" .. PREFIX .. "q", M.open_quick, {
    desc = "Quick dashboard",
  })

  vim.api.nvim_create_user_command("SahaDisk", function(args)
    if args.bang then
      -- :SahaDisk! — force a fresh open even if the float exists
      ui.close()
    end
    ui.toggle()
  end, { desc = "Toggle SahaDisk floating window", bang = true })

  vim.api.nvim_create_user_command("SahaDiskDoctor", function(args)
    open_cmd("doctor", { title = " SahaDisk doctor " })
  end, { desc = "SahaDisk: run doctor diagnostics" })

  vim.api.nvim_create_user_command("SahaDiskCleanup", function(args)
    open_cmd("cleanup", { title = " SahaDisk cleanup " })
  end, { desc = "SahaDisk: open cleanup engine" })

  vim.api.nvim_create_user_command("SahaDiskDocker", function()
    open_cmd("docker", { title = " SahaDisk docker " })
  end, { desc = "SahaDisk: open Docker management" })

  vim.api.nvim_create_user_command("SahaDiskQuick", function()
    open_cmd("quick", { title = " SahaDisk quick " })
  end, { desc = "SahaDisk: open quick health dashboard" })
end

-- Default TUI (no subcommand).
function M.open_default()
  ui.toggle()
end

function M.open_doctor()
  open_cmd("doctor", { title = " SahaDisk doctor " })
end

function M.open_cleanup()
  open_cmd("cleanup", { title = " SahaDisk cleanup " })
end

function M.open_docker()
  open_cmd("docker", { title = " SahaDisk docker " })
end

function M.open_quick()
  open_cmd("quick", { title = " SahaDisk quick " })
end

return M
