local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

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
