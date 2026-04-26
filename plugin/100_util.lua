local add = vim.pack.add
add({
	"https://github.com/chentoast/marks.nvim",
})

require("marks").setup({
	default_mappings = true,
})
