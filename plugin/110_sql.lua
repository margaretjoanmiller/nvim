-- ┌─────────────────────────┐
-- │ SQL / Database (dadbod) │
-- └─────────────────────────┘
--
-- vim-dadbod:          core database interaction
-- vim-dadbod-ui:       drawer UI for connections, queries, and results
-- vim-dadbod-completion: SQL completion (integrated with blink.cmp)

local add = vim.pack.add

add({
	"https://github.com/tpope/vim-dadbod",
	"https://github.com/kristijanhusak/vim-dadbod-ui",
	"https://github.com/kristijanhusak/vim-dadbod-completion",
})

-- dadbod-ui settings ----------------------------------------------------------

vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_show_database_icon = 1
vim.g.db_ui_winwidth = 40
vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/dadbod_ui_queries"
vim.g.db_ui_execute_on_save = 0
vim.g.db_ui_force_echo_notifications = 1

-- Keymaps (<Leader>q = Query) -------------------------------------------------

local nmap_leader = function(suffix, rhs, desc)
	vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

nmap_leader("qo", "<Cmd>DBUIToggle<CR>", "Toggle DB UI")
nmap_leader("qa", "<Cmd>DBUIAddConnection<CR>", "Add connection")
nmap_leader("qf", "<Cmd>DBUIFindBuffer<CR>", "Find query buffer")
nmap_leader("ql", "<Cmd>DBUILastQueryInfo<CR>", "Last query info")
nmap_leader("qr", "<Plug>(DBUI_ExecuteQuery)", "Execute query")

-- Optional: predefine connections (avoid committing secrets).
-- vim.g.dbs = {
--   { name = 'dev', url = 'postgres://user:pass@localhost/dbname' },
-- }
