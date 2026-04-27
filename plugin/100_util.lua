local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

later(function()
	add({
		"https://github.com/chentoast/marks.nvim",
	})

	require("marks").setup({
		default_mappings = true,
	})
end)

later(function()
	add({
		"https://github.com/vyfor/cord.nvim",
	})

	require("cord").setup()
end)
