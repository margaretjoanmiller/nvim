--- Neotest

local add = vim.pack.add
local later = Config.later

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

later(function()
	add({
		"https://github.com/nvim-neotest/nvim-nio",
		"https://github.com/nvim-lua/plenary.nvim",
		"https://github.com/nvim-neotest/neotest",
		"https://github.com/marilari88/neotest-vitest",
		"https://github.com/arthur944/neotest-bun",
		"https://github.com/nvim-neotest/neotest-go",
	})

	require("neotest").setup({
		adapters = {
			require("neotest-vitest"),
			require("neotest-bun"),
			require("neotest-go"),
		},
	})
end)
