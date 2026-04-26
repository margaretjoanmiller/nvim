-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- Each mini.* module is enabled independently via `require('mini.xxx').setup()`.
-- See `:h mini.nvim-general-principles`.
--

local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Step one ===================================================================

-- mini.basics: sensible mappings (<C-hjkl> window nav, <M-hjkl> insert nav, etc.)
now(function()
	require("mini.basics").setup({
		options = { basic = false }, -- Options managed in plugin/10_options.lua
		mappings = {
			windows = true,
			move_with_alt = true,
		},
	})
end)

-- mini.icons: icon provider used by mini.files, lualine (via web-devicons mock), etc.
now(function()
	local ext3_blocklist = { scm = true, txt = true, yml = true }
	local ext4_blocklist = { json = true, yaml = true }
	require("mini.icons").setup({
		use_file_extension = function(ext, _)
			return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
		end,
	})
	-- Mock nvim-web-devicons for plugins that hard-require it (lualine, etc.)
	later(MiniIcons.mock_nvim_web_devicons)
	-- LSP kind icons for completion menus
	later(MiniIcons.tweak_lsp_kind)
end)

-- mini.sessions: :h mksession wrapper
now(function()
	require("mini.sessions").setup()
end)

-- mini.starter: start screen when opening `nvim` with no args
now(function()
	require("mini.starter").setup()
end)

-- mini.tabline: buffers-as-tabs line at the top
now(function()
	require("mini.tabline").setup()
end)

-- Step one or two ============================================================

-- -- mini.misc: auto-root, restore-cursor, termbg-sync
now(function()
	require("mini.misc").setup()
	MiniMisc.setup_auto_root()
	MiniMisc.setup_restore_cursor()
	MiniMisc.setup_termbg_sync()
end)

-- Step two ===================================================================

-- mini.extra: ai-specs, highlighters (pickers not used - snacks.picker instead)
later(function()
	require("mini.extra").setup()
end)

-- mini.ai: extended a/i text objects
later(function()
	local ai = require("mini.ai")
	ai.setup({
		custom_textobjects = {
			B = MiniExtra.gen_ai_spec.buffer(),
			F = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			C = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
		},
		search_method = "cover",
	})
end)

-- mini.align: interactive alignment (ga / gA)
later(function()
	require("mini.align").setup()
end)

-- mini.bracketed: `[x` / `]x` navigation mappings
later(function()
	require("mini.bracketed").setup()
end)

-- mini.bufremove: safer buffer deletion used by <Leader>b{d,w}
later(function()
	require("mini.bufremove").setup()
end)

-- mini.clue: which-key-style next-key hints
later(function()
	local miniclue = require("mini.clue")
  -- stylua: ignore
  miniclue.setup({
    window = {
      delay = 500,
    },
    clues = {
      Config.leader_group_clues,
      miniclue.gen_clues.builtin_completion(),
      miniclue.gen_clues.g(),
      miniclue.gen_clues.marks(),
      miniclue.gen_clues.registers(),
      miniclue.gen_clues.square_brackets(),
      miniclue.gen_clues.windows({ submode_resize = true }),
      miniclue.gen_clues.z(),
    },
    triggers = {
      { mode = { 'n', 'x' }, keys = '<Leader>' },
      { mode =   'n',        keys = '\\' },
      { mode = { 'n', 'x' }, keys = '[' },
      { mode = { 'n', 'x' }, keys = ']' },
      { mode =   'i',        keys = '<C-x>' },
      { mode = { 'n', 'x' }, keys = 'g' },
      { mode = { 'n', 'x' }, keys = "'" },
      { mode = { 'n', 'x' }, keys = '`' },
      { mode = { 'n', 'x' }, keys = '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 's' },
      { mode = { 'n', 'x' }, keys = 'z' },
    },
  })
end)

-- -- mini.cmdline: autocomplete/autocorrect/peek in command line
-- later(function()
-- 	require("mini.cmdline").setup()
-- end)

-- mini.comment: gcip / gcgc etc.
later(function()
	require("mini.comment").setup()
end)

-- mini.diff: buffer-vs-git-index hunks; gh / gH ops, <Leader>go overlay toggle
later(function()
	require("mini.diff").setup()
end)

-- mini.git: :Git user command, MiniGit.show_at_cursor
later(function()
	require("mini.git").setup()
end)

-- mini.hipatterns: TODO/FIXME/hex color highlights
later(function()
	local hipatterns = require("mini.hipatterns")
	local hi_words = MiniExtra.gen_highlighter.words
	hipatterns.setup({
		highlighters = {
			fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
			hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
			todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
			note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
			hex_color = hipatterns.gen_highlighter.hex_color(),
		},
	})
end)

-- mini.jump: smarter fFtT
later(function()
	require("mini.jump").setup()
end)

-- mini.jump2d: label-based in-window jumping (<CR> to trigger)
later(function()
	require("mini.jump2d").setup()
end)

-- mini.move: move lines/selections with <M-hjkl>
later(function()
	require("mini.move").setup()
end)

-- mini.operators: gr (replace), gm (multiply), gs (sort), gx (exchange), g= (eval)
later(function()
	require("mini.operators").setup()
	-- Swap adjacent arguments: ( swap-left, ) swap-right
	vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
	vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })
end)

-- mini.pairs: autopairs in insert + command modes
later(function()
	require("mini.pairs").setup({ modes = { command = true } })
end)

-- mini.snippets: snippet manager. blink.cmp uses this as its snippet provider.
later(function()
	local latex_patterns = { "latex/**/*.json", "**/latex.json" }
	local lang_patterns = {
		tex = latex_patterns,
		plaintex = latex_patterns,
		markdown_inline = { "markdown.json" },
	}

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")
	snippets.setup({
		snippets = {
			snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
			snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
		},
	})
end)

-- mini.splitjoin: gS toggles joined/split arguments
later(function()
	require("mini.splitjoin").setup()
end)

-- mini.surround: sa / sd / sr / sf / sh (around cursor + n/l variants)
later(function()
	require("mini.surround").setup({
		mappings = {
			add = "<C-s>a", -- Add surrounding in Normal and Visual modes
			delete = "<C-s>d", -- Delete surrounding
			find = "<C-s>f", -- Find surrounding (to the right)
			find_left = "<C-s>F", -- Find surrounding (to the left)
			highlight = "<C-s>h", -- Highlight surrounding
			replace = "<C-s>r", -- Replace surrounding

			suffix_last = "l", -- Suffix to search with "prev" method
			suffix_next = "n", -- Suffix to search with "next" method
		},
	})
end)

-- mini.trailspace: highlight + <Leader>ot trims
later(function()
	require("mini.trailspace").setup()
end)

-- mini.visits: path-visit tracking, labels; powers <Leader>v* and some pickers
later(function()
	require("mini.visits").setup()
end)
