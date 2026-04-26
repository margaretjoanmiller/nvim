-- ┌────────────────────┐
-- │ LSP config example │
-- └────────────────────┘
--
-- This file contains configuration of 'lua_ls' language server.
-- Source: https://github.com/LuaLS/lua-language-server
--
-- It is used by `:h vim.lsp.enable()` and `:h vim.lsp.config()`.
-- See `:h vim.lsp.Config` and `:h vim.lsp.ClientConfig` for all available fields.
--
-- This config is designed for Lua's activity around Neovim. It provides only
-- basic config and can be further improved.
-- lua_ls: Lua language server. lazydev.nvim (plugin/70_blink.lua) handles
-- library-path expansion for plugin API completion, so we don't need to load
-- the entire vim runtime or plugin dirs here.
return {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				ignoreSubmodules = true,
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
			completion = { callSnippet = "Replace" },
			hint = {
				enable = true,
				arrayIndex = "Disable",
				setType = true,
				paramName = "Disable",
				paramType = true,
			},
			diagnostics = {
				globals = { "vim", "Config", "Snacks", "MiniIcons", "MiniFiles", "MiniMisc", "MiniExtra", "MiniVisits", "MiniSessions", "MiniBufremove", "MiniGit", "MiniDiff", "MiniTrailspace" },
			},
		},
	},
}
