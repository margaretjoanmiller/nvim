-- ┌──────────────────┐
-- │ Markdown rendering │
-- └──────────────────┘

local add = vim.pack.add
local later = Config.later

later(function()
	add({ "https://github.com/MeanderingProgrammer/render-markdown.nvim" })
	require("render-markdown").setup({
		completions = { blink = { enabled = true } },
		-- Latex rendering requires `latex2text` on PATH; disabled by default.
		latex = { enabled = false },
	})
end)
