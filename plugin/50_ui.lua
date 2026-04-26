-- ┌────────────────┐
-- │ UI: statusline │
-- └────────────────┘
--
-- Notifications come from snacks.notifier (plugin/60_snacks.lua).
-- Tabline comes from mini.tabline (plugin/30_mini.lua).

local add = vim.pack.add
local later = Config.later

add({
	"https://github.com/SmiteshP/nvim-navic",
	"https://github.com/nvim-lualine/lualine.nvim",
})

-- navic: symbol breadcrumb used in lualine below
require("nvim-navic").setup({
	lsp = { auto_attach = true },
	highlight = true,
})

require("lualine").setup({
	options = {
		theme = "auto",
		component_separators = "",
		section_separators = { left = "", right = "" },
		globalstatus = true,
	},
	sections = {
		lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
		lualine_b = { "branch", "filename" },
		lualine_c = {
			{
				"diagnostics",
				symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
			},
			{
				function()
					return require("nvim-navic").get_location()
				end,
				cond = function()
					return require("nvim-navic").is_available()
				end,
			},
		},
		lualine_x = {
			{ "diff", symbols = { added = "+", modified = "~", removed = "-" } },
			"filetype",
		},
		lualine_y = { "progress" },
		lualine_z = {
			{ "location", separator = { right = "" }, left_padding = 2 },
		},
	},
	inactive_sections = {
		lualine_a = { "filename" },
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = { "location" },
	},
	tabline = {},
	extensions = { "lazy", "mason", "quickfix" },
})

later(function()
	add({
		"https://github.com/hasansujon786/nvim-navbuddy",
	})

	local navbuddy = require("nvim-navbuddy")
	local actions = require("nvim-navbuddy.actions")

	navbuddy.setup({
		window = {
			border = "double", -- "rounded", "double", "solid", "none"
			-- or an array with eight chars building up the border in a clockwise fashion
			-- starting with the top-left corner. eg: { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" }.
			size = "60%", -- Or table format example: { height = "40%", width = "100%"}
			position = "50%", -- Or table format example: { row = "100%", col = "0%"}
			scrolloff = nil, -- scrolloff value within navbuddy window
			sections = {
				left = {
					size = "20%",
					border = nil, -- You can set border style for each section individually as well.
				},
				mid = {
					size = "40%",
					border = nil,
				},
				right = {
					-- No size option for right most section. It fills to
					-- remaining area.
					border = nil,
					preview = "leaf", -- Right section can show previews too.
					-- Options: "leaf", "always" or "never"
				},
			},
		},
		node_markers = {
			enabled = true,
			icons = {
				leaf = "  ",
				leaf_selected = " → ",
				branch = " ",
			},
		},
		icons = {
			File = "󰈙 ",
			Module = " ",
			Namespace = "󰌗 ",
			Package = " ",
			Class = "󰌗 ",
			Method = "󰆧 ",
			Property = " ",
			Field = " ",
			Constructor = " ",
			Enum = "󰕘",
			Interface = "󰕘",
			Function = "󰊕 ",
			Variable = "󰆧 ",
			Constant = "󰏿 ",
			String = " ",
			Number = "󰎠 ",
			Boolean = "◩ ",
			Array = "󰅪 ",
			Object = "󰅩 ",
			Key = "󰌋 ",
			Null = "󰟢 ",
			EnumMember = " ",
			Struct = "󰌗 ",
			Event = " ",
			Operator = "󰆕 ",
			TypeParameter = "󰊄 ",
		},
		use_default_mappings = true, -- If set to false, only mappings set
		-- by user are set. Else default
		-- mappings are used for keys
		-- that are not set by user
		mappings = {
			["<esc>"] = actions.close(), -- Close and cursor to original location
			["q"] = actions.close(),

			["j"] = actions.next_sibling(), -- down
			["k"] = actions.previous_sibling(), -- up

			["h"] = actions.parent(), -- Move to left panel
			["l"] = actions.children(), -- Move to right panel
			["0"] = actions.root(), -- Move to first panel

			["v"] = actions.visual_name(), -- Visual selection of name
			["V"] = actions.visual_scope(), -- Visual selection of scope

			["y"] = actions.yank_name(), -- Yank the name to system clipboard "+
			["Y"] = actions.yank_scope(), -- Yank the scope to system clipboard "+

			["i"] = actions.insert_name(), -- Insert at start of name
			["I"] = actions.insert_scope(), -- Insert at start of scope

			["a"] = actions.append_name(), -- Insert at end of name
			["A"] = actions.append_scope(), -- Insert at end of scope

			["r"] = actions.rename(), -- Rename currently focused symbol

			["d"] = actions.delete(), -- Delete scope

			["f"] = actions.fold_create(), -- Create fold of current scope
			["F"] = actions.fold_delete(), -- Delete fold of current scope

			["c"] = actions.comment(), -- Comment out current scope

			["<enter>"] = actions.select(), -- Goto selected symbol
			["o"] = actions.select(),

			["J"] = actions.move_down(), -- Move focused node down
			["K"] = actions.move_up(), -- Move focused node up

			["s"] = actions.toggle_preview(), -- Show preview of current node

			["<C-v>"] = actions.vsplit(), -- Open selected node in a vertical split
			["<C-s>"] = actions.hsplit(), -- Open selected node in a horizontal split

			["t"] = actions.telescope({ -- Fuzzy finder at current level.
				layout_config = { -- All options that can be
					height = 0.60, -- passed to telescope.nvim's
					width = 0.60, -- default can be passed here.
					prompt_position = "top",
					preview_width = 0.50,
				},
				layout_strategy = "horizontal",
			}),

			["g?"] = actions.help(), -- Open mappings help window
		},
		lsp = {
			auto_attach = true, -- If set to true, you don't need to manually use attach function
			preference = nil, -- list of lsp server names in order of preference
		},
		source_buffer = {
			follow_node = true, -- Keep the current node in focus on the source buffer
			highlight = true, -- Highlight the currently focused node
			reorient = "smart", -- "smart", "top", "mid" or "none"
			scrolloff = nil, -- scrolloff value when navbuddy is open
		},
		custom_hl_group = nil, -- "Visual" or any other hl group to use instead of inverted colors
	})

	vim.keymap.set("n", "<Leader>ln", function()
		require("nvim-navbuddy").open()
	end, { desc = "Navbuddy" })
end)

later(function()
	add({
		"https://github.com/MunifTanjim/nui.nvim",
		"https://github.com/folke/noice.nvim",
	})
	require("noice").setup({
		lsp = {
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = false, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = true, -- add a border to hover docs and signature help
		},
		hover = {
			enabled = false,
		},
	})
end)

later(function()
	add({
		"https://github.com/folke/trouble.nvim",
	})

	vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble" })

	vim.keymap.set(
		"n",
		"<leader>xX",
		"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
		{ desc = "Trouble: Current Buffer" }
	)

	vim.keymap.set(
		"n",
		"<leader>cs",
		"<cmd>Trouble symbols toggle focus=false<cr>",
		{ desc = "Trouble: Toggle Symbols" }
	)

	vim.keymap.set(
		"n",
		"<leader>cl",
		"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
		{ desc = "Trouble: Toggle LSP" }
	)

	vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble: Location List" })

	vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble quickfix toggle<cr>", { desc = "Trouble: Quickfix" })
end)

later(function()
	add({
		"https://github.com/folke/twilight.nvim",
	})

	require("twilight").setup()

	vim.keymap.set("n", "<leader>ut", "<cmd>Twilight<cr>", { desc = "Twilight" })
end)
