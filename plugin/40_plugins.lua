-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- Core tooling: tree-sitter, LSP (+lspconfig), mason, formatting, linting,
-- language-specific plugins (rustaceanvim), colorscheme.

local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Colorscheme ================================================================
-- Tokyonight is set during `now()` so first screen draw is already themed.
now(function()
	add({ "https://github.com/folke/tokyonight.nvim" })
	vim.cmd("colorscheme tokyonight-night")
end)

-- Tree-sitter ================================================================
now_if_args(function()
	-- Re-run :TSUpdate when nvim-treesitter updates
	Config.on_packchanged("nvim-treesitter", { "update" }, function()
		vim.cmd("TSUpdate")
	end, ":TSUpdate")

	add({
		"https://github.com/nvim-treesitter/nvim-treesitter",
		"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	})

	local languages = {
		-- Core
		"lua",
		"vim",
		"vimdoc",
		"query",
		"regex",
		"bash",
		-- Config / data
		"json",
		"json5",
		"yaml",
		"toml",
		"ini",
		-- Markup
		"markdown",
		"markdown_inline",
		"html",
		"css",
		"scss",
		-- Dev languages
		"typescript",
		"templ",
		"tsx",
		"javascript",
		"jsdoc",
		"go",
		"gomod",
		"gosum",
		"gowork",
		"rust",
		-- Git
		"gitcommit",
		"gitignore",
		"git_rebase",
		"diff",
		-- Misc useful
		"sql",
		"dockerfile",
		"make",
	}

	local isnt_installed = function(lang)
		return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
	end
	local to_install = vim.tbl_filter(isnt_installed, languages)
	if #to_install > 0 then
		require("nvim-treesitter").install(to_install)
	end

	-- Auto-start tree-sitter for target filetypes
	local filetypes = {}
	for _, lang in ipairs(languages) do
		for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
			table.insert(filetypes, ft)
		end
	end
	Config.new_autocmd("FileType", filetypes, function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end, "Start tree-sitter")
end)

-- Mason + tool installer =====================================================
-- mason.nvim manages external LSPs/formatters/linters/DAPs.
-- mason-tool-installer handles ensure_installed for ALL tool kinds (mason's own
-- ensure_installed only works with language servers in newer versions).
now_if_args(function()
	add({
		"https://github.com/mason-org/mason.nvim",
		"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	})

	require("mason").setup()
	require("mason-tool-installer").setup({
		ensure_installed = {
			-- LSP servers (nvim-lspconfig names / mason names)
			"lua-language-server",
			"tsgo",
			"gopls",
			"templ",
			"copilot-language-server",
			"rust-analyzer",
			"tailwindcss-language-server",
			"json-lsp",
			"yaml-language-server",
			"bash-language-server",
			"taplo", -- toml
			"ruff",
			"ty",
			-- Formatters
			"stylua",
			"biome",
			"prettierd",
			"gofumpt",
			"goimports",
			"shfmt",
			-- Linters
			"eslint_d",
			"golangci-lint",
			"sqruff",
			"harper-ls",
			-- DAP adapters
			"delve",
			"codelldb",
			"js-debug-adapter",
		},
		auto_update = false,
		run_on_start = true,
	})
end)

-- LSP =========================================================================
-- blink.cmp capabilities are registered in plugin/70_blink.lua during its
-- own setup (it runs `vim.lsp.config('*', { capabilities = ... })`).
now_if_args(function()
	add({
		"https://github.com/neovim/nvim-lspconfig",
	})

	-- Per-server overrides go in after/lsp/<server>.lua
	vim.lsp.enable({
		"lua_ls",
		"copilot",
		"tsgo",
		"gopls",
		"tailwindcss",
		"jsonls",
		"yamlls",
		"bashls",
		"taplo",
		"ty",
		"ruff",
		"harper_ls",
		"templ",
		-- rust_analyzer is deliberately handled by rustaceanvim, not enabled here.
	})

	-- LSP-aware keymaps set on attach (buffer-local). Supplements the
	-- <Leader>l* mappings in plugin/20_keymaps.lua.
	Config.new_autocmd("LspAttach", nil, function(ev)
		local buf = ev.buf
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
		end
		-- Inlay hints toggle (supported servers only)
		if vim.lsp.inlay_hint then
			pcall(vim.lsp.inlay_hint.enable, true, { bufnr = buf })
			map("n", "<Leader>lI", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
			end, "Toggle inlay hints")
		end
	end, "LSP buffer setup")
end)

-- Rust =======================================================================
-- rustaceanvim sets up rust_analyzer itself with extra DAP/test/macro features.
-- Do NOT `vim.lsp.enable('rust_analyzer')` above.
later(function()
	add({
		{
			src = "https://github.com/mrcjkb/rustaceanvim",
			version = vim.version.range("^9"),
		},
	})
	vim.g.rustaceanvim = {
		server = {
			default_settings = {
				["rust-analyzer"] = {
					cargo = { allFeatures = true },
					checkOnSave = { command = "clippy" },
					inlayHints = {
						bindingModeHints = { enable = true },
						closureReturnTypeHints = { enable = "always" },
						lifetimeElisionHints = { enable = "skip_trivial" },
					},
				},
			},
		},
	}
end)

-- Formatting (conform.nvim) ==================================================
later(function()
	add({ "https://github.com/stevearc/conform.nvim" })

	require("conform").setup({
		default_format_opts = {
			lsp_format = "fallback",
			timeout_ms = 3000,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			-- JS/TS via biome (fast, no config required for defaults)
			javascript = { "biome" },
			javascriptreact = { "biome" },
			typescript = { "biome" },
			typescriptreact = { "biome" },
			json = { "biome" },
			jsonc = { "biome" },
			-- Python
			python = { "ruff_format", "ruff_organize_imports" },
			-- Go
			go = { "goimports", "gofumpt" },
			-- Rust (rustaceanvim/rust-analyzer handles this too; conform as fallback)
			rust = { "rustfmt", lsp_format = "fallback" },
			-- Shell
			sh = { "shfmt" },
			bash = { "shfmt" },
			-- Markup
			css = { "biome" },
			scss = { "biome" },
			html = { "prettierd" },
			yaml = { "prettierd" },
			toml = { "taplo" },
			markdown = { "prettierd" },
		},
		format_on_save = function(bufnr)
			-- Allow per-buffer opt-out: `:lua vim.b.disable_autoformat = true`
			if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
				return
			end
			return { lsp_format = "fallback", timeout_ms = 3000 }
		end,
	})

	-- Commands to toggle format-on-save at buffer or global scope
	vim.api.nvim_create_user_command("FormatDisable", function(args)
		if args.bang then
			vim.b.disable_autoformat = true
		else
			vim.g.disable_autoformat = true
		end
	end, { desc = "Disable autoformat", bang = true })
	vim.api.nvim_create_user_command("FormatEnable", function()
		vim.b.disable_autoformat = false
		vim.g.disable_autoformat = false
	end, { desc = "Enable autoformat" })
end)

-- Linting (nvim-lint) ========================================================
later(function()
	add({ "https://github.com/mfussenegger/nvim-lint" })

	local lint = require("lint")
	lint.linters_by_ft = {
		javascript = { "biomejs" },
		javascriptreact = { "biomejs" },
		typescript = { "biomejs" },
		typescriptreact = { "biomejs" },
		go = { "golangcilint" },
		sql = { "sqruff" },
	}

	-- Debounce/trigger lints on common events
	Config.new_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, nil, function()
		-- try_lint is a no-op when no linter is configured for the filetype
		require("lint").try_lint()
	end, "Run nvim-lint")
end)

-- Snippets library ===========================================================
later(function()
	add({ "https://github.com/rafamadriz/friendly-snippets" })
end)

add({
	"https://github.com/folke/flash.nvim",
})
require("flash").setup()
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

-- Utils ===================================

later(function()
	add({
		"https://github.com/MunifTanjim/nui.nvim",
		"https://github.com/m4xshen/hardtime.nvim",
	})

	require("hardtime").setup({
		disable_mouse = false,
	})
end)

later(function()
	add({
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/epwalsh/obsidian.nvim",
	})

	require("obsidian").setup({
		workspaces = {
			{
				name = "core",
				path = "~/Documents/core",
			},
		},
	})
end)

add({
	"https://github.com/hiphish/rainbow-delimiters.nvim",
})
require("rainbow-delimiters.setup").setup()

later(function()
	add({
		"https://github.com/mrjones2014/smart-splits.nvim",
	})

	vim.keymap.set("n", "<A-h>", function()
		require("smart-splits").resize_left()
	end)
	vim.keymap.set("n", "<A-j>", function()
		require("smart-splits").resize_down()
	end)
	vim.keymap.set("n", "<A-k>", function()
		require("smart-splits").resize_up()
	end)
end)

later(function()
	add({
		"https://github.com/gbprod/yanky.nvim",
	})

	require("yanky").setup()
end)

later(function()
	add({ "https://github.com/andrewferrier/wrapping.nvim" })

	require("wrapping").setup()
end)

add({
	"https://github.com/windwp/nvim-ts-autotag",
})

require("nvim-ts-autotag").setup({
	filetypes = { "html", "xml", "php", "javascriptreact", "typescriptreact", "templ" },
})
