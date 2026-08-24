-- ╔══════════════════════════════════════════════════════════════════════════════╗
-- ║                          GENTLEMAN DOTS - WEZTERM                            ║
-- ║                           Optimized for Neovim                               ║
-- ╚══════════════════════════════════════════════════════════════════════════════╝

local wezterm = require("wezterm")
local config = {}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                                   FONT                                       │
-- └──────────────────────────────────────────────────────────────────────────────┘

config.font = wezterm.font("IosevkaTerm NF")
config.font_size = 12.0

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                                  WINDOW                                      │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- Remove the native Windows title bar but keep minimize/maximize/close buttons
-- rendered inside the tab bar (INTEGRATED_BUTTONS). RESIZE keeps the resizable
-- border so the window can still be resized by dragging its edges.
-- NOTE: window decorations are applied when a window is CREATED. A config
-- reload does NOT strip the native title bar from an existing window; you must
-- close ALL WezTerm windows and open them again.
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- Glass blur: Acrylic is the Windows "blur-behind-window" effect (Win 10+).
-- It uses more resources than Mica/Tabbed, but it is the only one that gives
-- true frosted-glass blur; opacity must be < 1.0 for the backdrop to apply.
-- 0.5 is the chosen level: the desktop shows through clearly while text
-- stays readable. Raise it (e.g. 0.75) for more contrast if needed.
-- NOTE: when the window is MAXIMIZED, Windows can disable the Acrylic blur
-- and fall back to a solid backdrop; test with a normal window first.
config.window_background_opacity = 0.5
config.macos_window_background_blur = 20
config.win32_system_backdrop = "Acrylic"

config.window_padding = {
	top = 0,
	right = 0,
	left = 0,
	bottom = 0,
}

config.enable_scroll_bar = false
-- The tab bar must stay visible: with INTEGRATED_BUTTONS the window buttons
-- live in the tab bar, and the "wezterm" title is rendered there too.
config.hide_tab_bar_if_only_one_tab = false

-- Retro tab bar instead of the native/fancy one. Two reasons:
--  1. With INTEGRATED_BUTTONS the window buttons are only themed via
--     tab_bar_style in the retro tab bar; the fancy one draws them with
--     default (native-looking) colors.
--  2. format-tab-title's max_width only drives layout in the retro bar,
--     which is what lets us center the "wezterm" title.
config.use_fancy_tab_bar = false
-- The default tab_max_width is 16 cells, which pins a single tab's title to
-- the left of the bar. A large value lets the centered padding resolve against
-- the full tab bar width (see format-tab-title below).
config.tab_max_width = 2000

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                         TAB BAR (THEMED CHROME)                              │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- With the retro tab bar, the integrated window buttons (minimize / maximize /
-- close) and the "+" tab button are themed here (config.colors.tab_bar lives
-- right after the palette), so nothing looks like a native Windows control.
-- The default glyphs are kept: " . ", " - ", " X ", " + ".
config.tab_bar_style = {
	window_hide = wezterm.format { { Foreground = { Color = "#8a8fa3" } }, { Text = " . " } },
	window_hide_hover = wezterm.format { { Foreground = { Color = "#f3f6f9" } }, { Text = " . " } },
	window_maximize = wezterm.format { { Foreground = { Color = "#8a8fa3" } }, { Text = " - " } },
	window_maximize_hover = wezterm.format { { Foreground = { Color = "#f3f6f9" } }, { Text = " - " } },
	window_close = wezterm.format { { Foreground = { Color = "#8a8fa3" } }, { Text = " X " } },
	window_close_hover = wezterm.format {
		{ Foreground = { Color = "#ffffff" } },
		{ Background = { Color = "#cb7c94" } },
		{ Text = " X " },
	},
	new_tab = wezterm.format { { Foreground = { Color = "#8a8fa3" } }, { Text = " + " } },
	new_tab_hover = wezterm.format { { Foreground = { Color = "#f3f6f9" } }, { Text = " + " } },
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                                  CURSOR                                      │
-- └──────────────────────────────────────────────────────────────────────────────┘

config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                            NEOVIM OPTIMIZATIONS                              │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- Terminal & Colors
-- WSL doesn't have wezterm terminfo, so we use xterm-256color there
-- See: https://github.com/Gentleman-Programming/Gentleman.Dots/issues/117
if wezterm.target_triple:find("windows") then
  config.term = "xterm-256color"
else
  config.term = "wezterm"
end
config.enable_csi_u_key_encoding = true

-- Undercurl support (LSP diagnostics, spelling)
config.underline_thickness = 2
config.underline_position = -2

-- Scrollback
config.scrollback_lines = 10000

-- Performance
-- OpenGL is the default GPU front-end on this version; WebGpu (D3D12/Vulkan)
-- and Software are only worth switching to if you hit GPU/driver issues.
config.front_end = "OpenGL"
-- 120 fps is 2x the documented default (60); 240 only wastes GPU work.
config.max_fps = 120
-- Cursor easing is Constant, so animated transitions don't need high fps;
-- lowering animation_fps reduces GPU utilization for blink effects.
config.animation_fps = 1

-- Image support
config.enable_kitty_graphics = true

-- Input handling
config.use_dead_keys = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                           GENTLEMAN THEME                                    │
-- └──────────────────────────────────────────────────────────────────────────────┘

config.colors = {
	-- Base Colors
	foreground = "#f3f6f9",
	background = "#06080f",

	-- Cursor
	cursor_bg = "#e0c15a",
	cursor_fg = "#06080f",
	cursor_border = "#e0c15a",

	-- Selection
	selection_fg = "#f3f6f9",
	selection_bg = "#263356",

	-- Normal Colors
	ansi = {
		"#06080f", -- black
		"#cb7c94", -- red
		"#b7cc85", -- green
		"#ffe066", -- yellow
		"#7fb4ca", -- blue
		"#ff8dd7", -- magenta
		"#7aa89f", -- cyan
		"#f3f6f9", -- white
	},

	-- Bright Colors
	brights = {
		"#8a8fa3", -- black
		"#de8fa8", -- red
		"#d1e8a9", -- green
		"#fff7b1", -- yellow
		"#a3d4d5", -- blue
		"#ffaeea", -- magenta
		"#7fb4ca", -- cyan
		"#f3f6f9", -- white
	},
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                          TAB BAR (THEMED CHROME)                              │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- The whole top strip (background + active/inactive tabs + the new-tab button)
-- takes the GENTLEMAN palette. Defined separately because config.colors is
-- assigned as a whole block above and would otherwise overwrite this table.
--
-- The strip is now translucent at the same alpha as the terminal (0.5): the
-- tab bar is painted after the window background, so an alpha'd bg_color lets
-- the Acrylic blur show through behind the title and the window buttons.
-- Format note: WezTerm does NOT accept #RRGGBBAA; the CSS rgba() form is the
-- supported way to carry an alpha channel (verified against the color parser).
config.colors.tab_bar = {
	-- The strip that runs along the top of the window
	background = "rgba(6, 8, 15, 0.5)",
	-- Active tab (with a single tab, the centered "wezterm" title lives here)
	active_tab = {
		bg_color = "rgba(6, 8, 15, 0.5)",
		fg_color = "#f3f6f9",
	},
	-- Inactive tabs (only visible with multiple tabs)
	inactive_tab = {
		bg_color = "rgba(11, 15, 28, 0.5)",
		fg_color = "#8a8fa3",
	},
	inactive_tab_hover = {
		bg_color = "rgba(20, 26, 46, 0.5)",
		fg_color = "#f3f6f9",
	},
	new_tab = {
		bg_color = "rgba(6, 8, 15, 0.5)",
		fg_color = "#8a8fa3",
	},
	new_tab_hover = {
		bg_color = "rgba(20, 26, 46, 0.5)",
		fg_color = "#f3f6f9",
	},
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                            WINDOWS (WSL)                                     │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- Uncomment for Windows/WSL:
-- config.default_domain = 'WSL:Ubuntu'

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │                          TAB TITLE ("wezterm")                              │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- No native API centers text in the tab bar. With a single tab the retro tab
-- bar lays the tab out across the full bar width, so padding the "wezterm"
-- title with half of the remaining max_width approximates true centering
-- (tab_max_width = 2000 so the padding resolves against the bar width, not the
-- default 16-cell cap). With multiple tabs, each tab keeps its own title so
-- the multi-tab UX is preserved.
wezterm.on("format-tab-title", function(tab, tabs, panes, win_config, hover, max_width)
  if #tabs == 1 then
    local title = "wezterm"
    local pad = math.max(0, math.floor((max_width - #title) / 2))
    return string.rep(" ", pad) .. title
  end
  -- Fall back to the default behavior for multiple tabs: explicit tab title
  -- if set, otherwise the title of the active pane in that tab.
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end
  return tab.active_pane.title
end)

return config