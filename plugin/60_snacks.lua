-- ┌──────────────────┐
-- │ snacks.nvim      │
-- └──────────────────┘
--
-- Used for: picker, notifier, input, terminal, scratch, zen, statuscolumn,
-- scroll, words, bigfile, quickfile, dim, toggle, lazygit, gitbrowse.
--
-- Deliberately disabled (handled elsewhere):
-- - explorer: mini.files is used instead (plugin/30_mini.lua)
-- - dashboard: mini.starter is used instead (plugin/30_mini.lua)
-- - image, layout: niche; enable later if wanted

local add = vim.pack.add
local now, later = Config.now, Config.later

-- Snacks needs to be required early for notifier/statuscolumn/quickfile to hook
-- in before other things. Keep `.setup` on `now`, defer keymaps to `later`.
now(function()
	add({ "https://github.com/folke/snacks.nvim" })

	local Snacks = require("snacks")

	Snacks.setup({
		-- Performance / QoL
		bigfile = { enabled = true },
		quickfile = { enabled = true },

		-- UI
		animate = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		input = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true }, -- Enables ]] / [[ Snacks.words.jump
		scroll = { enabled = true },
		dim = { enabled = true },
		scope = { enabled = true },
		indent = { enabled = true },

		-- Features
		rename = { enabled = true },
		image = { enabled = true },
		gh = { enabled = true },
		git = { enabled = true },

		picker = {
			sources = {
				files = {
					hidden = true,
					ignored = false,
					exclude = {
						"**/.git/*",
						"**/node_modules/*",
						"**/.yarn/cache/*",
						"**/.pnpm-store/*",
						"**/target/*",
						"**/dist/*",
						"**/build/*",
						"**/coverage/*",
						"**/.DS_Store",
					},
				},
				grep = {
					hidden = true,
					ignored = false,
					exclude = {
						"**/.git/*",
						"**/node_modules/*",
						"**/.yarn/cache/*",
						"**/.pnpm-store/*",
						"**/target/*",
						"**/dist/*",
						"**/build/*",
						"**/coverage/*",
						"**/.DS_Store",
						"**/*.lock",
					},
				},
			},
		},
		scratch = { enabled = true },
		terminal = { enabled = true },
		toggle = { enabled = true },
		zen = { enabled = true },

		explorer = { enabled = true },
		dashboard = { enabled = false }, -- mini.starter instead
	})
end)

-- Register toggle mappings and picker keymaps lazily.
later(function()
	local Snacks = require("snacks")

	-- Togglers (<Leader>u*)
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<Leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<Leader>uw")
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<Leader>uL")
	Snacks.toggle.diagnostics():map("<Leader>ud")
	Snacks.toggle.line_number():map("<Leader>ul")
	Snacks.toggle.treesitter():map("<Leader>uT")
	Snacks.toggle.dim():map("<Leader>uD")
	Snacks.toggle.scroll():map("<Leader>uS")
	Snacks.toggle.zoom():map("<Leader>uZ")
	Snacks.toggle.zen():map("<Leader>uz")
end)

-- Snacks keymaps. These are registered inside `later()` because Snacks is
-- already loaded in `now()` above. See plugin/20_keymaps.lua for the
-- non-snacks keymaps.
--
-- Leader groups used here (also listed in Config.leader_group_clues):
-- - <Leader>f: Find (files, grep, etc.)
-- - <Leader>s: Search (lines, diagnostics, etc.)
-- - <Leader>g: Git
-- - <Leader>u: UI toggles
-- - <Leader>n: Notifications
-- - <Leader>.: Scratch buffer
-- - <Leader>z: Zen
later(function()
	local Snacks = require("snacks")

	-- stylua: ignore start
	local keymaps = {
		-- Top pickers
		{ "<Leader><Space>", function() Snacks.picker.smart() end,             desc = "Smart find files" },
		{ "<Leader>/",       function() Snacks.picker.grep() end,              desc = "Grep" },
		{ "<Leader>:",       function() Snacks.picker.command_history() end,   desc = "Command history" },
		{ "<Leader>,",       function() Snacks.picker.buffers() end,           desc = "Buffers" },

    {"<Leader>ee", function () Snacks.explorer() end, desc = "Explorer"},

		-- Find
		{ "<Leader>ff", function() Snacks.picker.files() end,                                    desc = "Files" },
		{ "<Leader>fb", function() Snacks.picker.buffers() end,                                  desc = "Buffers" },
		{ "<Leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,  desc = "Config files" },
		{ "<Leader>fg", function() Snacks.picker.git_files() end,                                desc = "Git files" },
		{ "<Leader>fh", function() Snacks.picker.help() end,                                     desc = "Help" },
		{ "<Leader>fr", function() Snacks.picker.recent() end,                                   desc = "Recent" },
		{ "<Leader>fR", function() Snacks.picker.resume() end,                                   desc = "Resume" },
		{ "<Leader>fp", function() Snacks.picker.projects() end,                                 desc = "Projects" },
		{ "<Leader>fd", function() Snacks.picker.diagnostics() end,                              desc = "Diagnostics (workspace)" },
		{ "<Leader>fD", function() Snacks.picker.diagnostics_buffer() end,                       desc = "Diagnostics (buffer)" },

		-- Search (within buffers / repo)
		{ "<Leader>sg", function() Snacks.picker.grep() end,                              desc = "Grep" },
		{ "<Leader>sw", function() Snacks.picker.grep_word() end,                         desc = "Grep word",        mode = { "n", "x" } },
		{ "<Leader>sb", function() Snacks.picker.lines() end,                             desc = "Buffer lines" },
		{ "<Leader>sB", function() Snacks.picker.grep_buffers() end,                      desc = "Grep open buffers" },
		{ "<Leader>s/", function() Snacks.picker.search_history() end,                    desc = "Search history" },
		{ "<Leader>sk", function() Snacks.picker.keymaps() end,                           desc = "Keymaps" },
		{ "<Leader>sm", function() Snacks.picker.marks() end,                             desc = "Marks" },
		{ "<Leader>sj", function() Snacks.picker.jumps() end,                             desc = "Jumps" },
		{ "<Leader>sr", function() Snacks.picker.registers() end,                         desc = "Registers" },
		{ "<Leader>sC", function() Snacks.picker.commands() end,                          desc = "Commands" },
		{ "<Leader>sH", function() Snacks.picker.highlights() end,                        desc = "Highlights" },
		{ "<Leader>si", function() Snacks.picker.icons() end,                             desc = "Icons" },
		{ "<Leader>sq", function() Snacks.picker.qflist() end,                            desc = "Quickfix" },
		{ "<Leader>su", function() Snacks.picker.undo() end,                              desc = "Undo history" },
		{ "<Leader>ss", function() Snacks.picker.lsp_symbols() end,                       desc = "LSP symbols (doc)" },
		{ "<Leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,             desc = "LSP symbols (workspace)" },

		-- Git
		{ "<Leader>gb", function() Snacks.picker.git_branches() end, desc = "Branches" },
		{ "<Leader>gl", function() Snacks.picker.git_log() end,      desc = "Log" },
		{ "<Leader>gL", function() Snacks.picker.git_log_line() end, desc = "Log (line)" },
		{ "<Leader>gS", function() Snacks.picker.git_stash() end,    desc = "Stash" },
		{ "<Leader>gp", function() Snacks.picker.git_diff() end,     desc = "Diff hunks" },
		{ "<Leader>gf", function() Snacks.picker.git_log_file() end, desc = "Log (file)" },
		{ "<Leader>gB", function() Snacks.gitbrowse() end,           desc = "Git browse",   mode = { "n", "v" } },
		{ "<Leader>gg", function() Snacks.lazygit() end,             desc = "Lazygit" },

		-- LSP (override <Leader>l* defaults in 20_keymaps where useful)
		{ "gd", function() Snacks.picker.lsp_definitions() end,       desc = "Definition" },
		{ "gD", function() Snacks.picker.lsp_declarations() end,      desc = "Declaration" },
		{ "gI", function() Snacks.picker.lsp_implementations() end,   desc = "Implementation" },
		{ "gy", function() Snacks.picker.lsp_type_definitions() end,  desc = "Type definition" },
		{ "gR", function() Snacks.picker.lsp_references() end,        desc = "References" },

		-- UI toggles
		{ "<Leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
		{ "<Leader>un", function() Snacks.notifier.hide() end,       desc = "Dismiss notifications" },

		-- Notifications
		{ "<Leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification history" },

		-- Terminal
		{ "<C-/>",      function() Snacks.terminal() end,                                        desc = "Toggle terminal" },
		{ "<C-_>",      function() Snacks.terminal() end,                                        desc = "Toggle terminal" }, -- some terminals send C-_ for C-/
		{ "<Leader>ft", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end,          desc = "Terminal (cwd)" },

		-- Scratch / zen / misc
		{ "<Leader>.",  function() Snacks.scratch() end,              desc = "Scratch buffer" },
		{ "<Leader>S",  function() Snacks.scratch.select() end,       desc = "Select scratch" },
		{ "<Leader>z",  function() Snacks.zen() end,                  desc = "Zen" },
		{ "<Leader>Z",  function() Snacks.zen.zoom() end,             desc = "Zen zoom" },

		-- Word references (Snacks.words)
		{ "]]", function() Snacks.words.jump(vim.v.count1) end,  desc = "Next reference",  mode = { "n", "t" } },
		{ "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference",  mode = { "n", "t" } },
	}
	-- stylua: ignore end

	for _, m in ipairs(keymaps) do
		vim.keymap.set(m.mode or "n", m[1], m[2], { desc = m.desc, silent = true, noremap = true })
	end
end)
