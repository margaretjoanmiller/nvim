-- ┌──────────────────────┐
-- │ blink.cmp completion │
-- └──────────────────────┘
--
-- blink.cmp is the completion engine. It integrates with:
-- - LSP (via capabilities registered in plugin/40_plugins.lua)
-- - mini.snippets (preset = "mini_snippets")
-- - lazydev.nvim (Lua completion for Neovim API)
-- - friendly-snippets (via mini.snippets loader)
-- - blink-ripgrep.nvim (fallback word search)
--
-- The rust fuzzy matcher is downloaded as a prebuilt binary matching the
-- installed plugin version. If the download fails blink automatically falls
-- back to the Lua implementation (with a warning).

local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Install blink and friends. Load `now_if_args` so completion is available
-- immediately when starting nvim on a file.
now_if_args(function()
	add({
		"https://github.com/jdrupal-dev/css-vars.nvim",
		"https://github.com/folke/lazydev.nvim",
		"https://github.com/mikavilpas/blink-ripgrep.nvim",
		"https://github.com/Kaiser-Yang/blink-cmp-git",
		"https://github.com/saghen/blink.lib",
		"https://github.com/saghen/blink.cmp",
	})

	-- lazydev: better Lua completion for Neovim API / runtime / plugin library
	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	})

	local blink = require("blink.cmp")
	blink.build():wait(6000)
	blink.setup({
		keymap = {
			-- 'super-tab': <Tab> accepts / expands snippets, <S-Tab> prev
			-- <C-Space> opens menu / docs, <C-n>/<C-p> navigate, <C-e> hides
			preset = "super-tab",
		},

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = {
			documentation = { auto_show = true, auto_show_delay_ms = 200 },
			menu = {
				draw = {
					components = {
						kind_icon = {
							text = function(ctx)
								local icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
								return (icon or "") .. (ctx.icon_gap or " ")
							end,
							highlight = function(ctx)
								local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
								return hl or "BlinkCmpKind" .. ctx.kind
							end,
						},
					},
				},
			},
			ghost_text = { enabled = true },
		},

		sources = {
			default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
			per_filetype = {
				lua = { "lazydev", "lsp", "path", "snippets", "buffer" },
				markdown = { "lsp", "path", "snippets", "buffer", "ripgrep" },
				gitcommit = { "git", "lsp", "path", "snippets", "buffer" },
				sql = { "dadbod", "lsp", "path", "snippets", "buffer" },
				typescriptreact = { "css_vars", "lsp", "path", "snippets", "buffer" },
				javascriptreact = { "css_vars", "lsp", "path", "snippets", "buffer" },
				typescript = { "css_vars", "lsp", "path", "snippets", "buffer" },
				javascript = { "css_vars", "lsp", "path", "snippets", "buffer" },
			},
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					---@module "blink-ripgrep"
					---@type blink-ripgrep.Options
					opts = {},
				},
				git = {
					module = "blink-cmp-git",
					name = "Git",
					opts = {},
				},
				css_vars = {
					name = "css-vars",
					module = "css-vars.blink",
					opts = {
						-- WARNING: The search is not optimized to look for variables in JS files.
						-- If you change the search_extensions you might get false positives and weird completion results.
						search_extensions = { ".js", ".ts", ".jsx", ".tsx" },
					},
				},
			},
		},

		-- Enable cmdline completion
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
			completion = {
				menu = { auto_show = true },
				ghost_text = { enabled = true },
			},
		},

		-- Use mini.snippets (set up in plugin/30_mini.lua) as snippet provider
		snippets = { preset = "mini_snippets" },

		-- Prefer native rust fuzzy matcher; fall back to lua with a warning.
		-- The prebuilt binary is downloaded by blink matching the plugin version.
		fuzzy = { implementation = "prefer_rust_with_warning" },

		signature = { enabled = true },
	})

	-- Register blink.cmp's LSP capabilities globally so every server advertises
	-- completion/snippet support. This runs after setup() so blink is ready.
	pcall(vim.lsp.config, "*", { capabilities = blink.get_lsp_capabilities() })
end)

-- Optional: blink-ripgrep source is referenced above but not in default sources.
-- Enable it explicitly as a buffer fallback if you want. To enable, add
-- "ripgrep" to `sources.default` or `sources.per_filetype` above.
