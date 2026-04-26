-- ┌───────────────┐
-- │ Debugging (DAP) │
-- └───────────────┘
--
-- nvim-dap + nvim-dap-ui + nvim-nio + per-language adapters.
-- Adapters installed via mason (see mason-tool-installer list in 40_plugins.lua):
-- - delve (go)
-- - codelldb (rust, c/c++)
-- - js-debug-adapter (node/typescript)
-- Rust debugging is preferentially handled through rustaceanvim.

local add = vim.pack.add
local later = Config.later

later(function()
	add({
		"https://github.com/mfussenegger/nvim-dap",
		"https://github.com/rcarriga/nvim-dap-ui",
		"https://github.com/nvim-neotest/nvim-nio",
		"https://github.com/theHamsta/nvim-dap-virtual-text",
		"https://github.com/leoluz/nvim-dap-go",
	})

	local dap = require("dap")
	local dapui = require("dapui")

	dapui.setup()
	require("nvim-dap-virtual-text").setup({ commented = true })

	-- Auto open/close dap-ui on session events
	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	-- Go: configure via nvim-dap-go (finds `dlv` on PATH via mason)
	require("dap-go").setup()

	dap.configurations.typescript = {
		{
			type = "pwa-node",
			request = "launch",
			name = "Launch file",
			program = "${file}",
			cwd = "${workspaceFolder}",
		},
	}

	-- Rust/C/C++: codelldb adapter (for non-rust or rust without rustaceanvim)
	if mason_reg_ok and mason_reg.is_installed("codelldb") then
		local codelldb_path = mason_reg.get_package("codelldb"):get_install_path() .. "/extension/adapter/codelldb"
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = codelldb_path,
				args = { "--port", "${port}" },
			},
		}
		-- rustaceanvim provides richer Rust configs; this is a minimal fallback.
		dap.configurations.rust = dap.configurations.rust or {}
	end

	-- Keymaps (<Leader>d group)
	local map = function(lhs, rhs, desc)
		vim.keymap.set("n", "<Leader>" .. lhs, rhs, { desc = desc })
	end

	-- stylua: ignore start
	map('db', function() dap.toggle_breakpoint() end,                                       'Toggle breakpoint')
	map('dB', function() dap.set_breakpoint(vim.fn.input('Condition: ')) end,               'Conditional breakpoint')
	map('dc', function() dap.continue() end,                                                'Continue')
	map('di', function() dap.step_into() end,                                               'Step into')
	map('do', function() dap.step_over() end,                                               'Step over')
	map('dO', function() dap.step_out() end,                                                'Step out')
	map('dr', function() dap.repl.toggle() end,                                             'Toggle REPL')
	map('dl', function() dap.run_last() end,                                                'Run last')
	map('dt', function() dap.terminate() end,                                               'Terminate')
	map('du', function() dapui.toggle() end,                                                'Toggle UI')
	map('de', function() dapui.eval() end,                                                  'Eval')
	-- stylua: ignore end
end)
