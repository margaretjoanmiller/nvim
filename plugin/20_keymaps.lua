-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- General + Leader mappings. Picker/search mappings live in plugin/60_snacks.lua.
-- LSP on-attach buffer-local mappings live in plugin/40_plugins.lua.

-- General mappings ===========================================================

local nmap = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { desc = desc })
end

-- Paste linewise before/after current line
nmap("[p", '<Cmd>exe "iput! " . v:register<CR>', "Paste Above")
nmap("]p", '<Cmd>exe "iput "  . v:register<CR>', "Paste Below")

-- Clear search highlight quickly
nmap("<Esc>", "<Cmd>nohlsearch<CR>", "Clear search highlight")

-- stylua: ignore start

-- Leader mappings ============================================================
-- Convention: two-key Leader mappings. First = semantic group; second = action.
-- Lowercase second key = global; uppercase = buffer-local variant where relevant.

-- Groups for mini.clue hints. Keep in sync with actual mappings below.
Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>d', desc = '+Debug' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  { mode = 'n', keys = '<Leader>l', desc = '+Language (LSP)' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>q', desc = '+Query (SQL)' },
  { mode = 'n', keys = '<Leader>s', desc = '+Search' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
  { mode = 'n', keys = '<Leader>u', desc = '+UI toggle' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },
  { mode = 'n', keys = '<Leader>w', desc = '+Write/Session' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  { mode = 'x', keys = '<Leader>l', desc = '+Language (LSP)' },
  { mode = 'x', keys = '<Leader>s', desc = '+Search' },
}

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc })
end
local xmap_leader = function(suffix, rhs, desc)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc })
end

-- b: Buffer ==================================================================
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader('ba', '<Cmd>b#<CR>',                                 'Alternate')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bs', new_scratch_buffer,                            'Scratch')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')

-- e: Explore/Edit ============================================================
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
local explore_quickfix = function()
  vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
end
local explore_locations = function()
  vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>',    'Directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>',           'init.lua')
nmap_leader('eq', explore_quickfix,                   'Quickfix list')
nmap_leader('eQ', explore_locations,                  'Location list')

-- f, s: Find/Search groups are defined in plugin/60_snacks.lua ===============

-- g: Git =====================================================================
-- Most fuzzy-find git pickers are in plugin/60_snacks.lua (<Leader>gb/gl/...).
-- These are buffer/diff actions that are not pickers.
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

nmap_leader('ga', '<Cmd>Git diff --cached<CR>',             'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>',        'Added diff (buf)')
nmap_leader('gc', '<Cmd>Git commit<CR>',                    'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>',            'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>',                      'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>',                 'Diff (buf)')
nmap_leader('gH', '<Cmd>' .. git_log_cmd .. '<CR>',         'Log (all)')
nmap_leader('gh', '<Cmd>' .. git_log_buf_cmd .. '<CR>',     'Log (buf)')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gx', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at cursor')

xmap_leader('gx', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l: Language (LSP) ==========================================================
-- Buffer-local LSP mappings are also set in plugin/40_plugins.lua on LspAttach.
nmap_leader('la', '<Cmd>lua vim.lsp.buf.code_action()<CR>',     'Code actions')
nmap_leader('ld', '<Cmd>lua vim.diagnostic.open_float()<CR>',   'Diagnostic popup')
nmap_leader('lf', '<Cmd>lua require("conform").format()<CR>',   'Format buffer')
nmap_leader('lh', '<Cmd>lua vim.lsp.buf.hover()<CR>',           'Hover')
nmap_leader('li', '<Cmd>lua vim.lsp.buf.implementation()<CR>',  'Implementation')
nmap_leader('ll', '<Cmd>lua vim.lsp.codelens.run()<CR>',        'Codelens')
nmap_leader('lr', '<Cmd>lua vim.lsp.buf.rename()<CR>',          'Rename')
nmap_leader('lR', '<Cmd>lua vim.lsp.buf.references()<CR>',      'References')
nmap_leader('ls', '<Cmd>lua vim.lsp.buf.definition()<CR>',      'Definition')
nmap_leader('lt', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', 'Type definition')
nmap_leader('lD', '<Cmd>lua vim.lsp.buf.declaration()<CR>',     'Declaration')
nmap_leader('lS', '<Cmd>lua vim.lsp.buf.signature_help()<CR>',  'Signature help')

xmap_leader('lf', '<Cmd>lua require("conform").format()<CR>', 'Format selection')

-- o: Other ===================================================================
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>',    'Trim trailspace')
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')

-- t: Terminal ================================================================
-- <Leader>ft is also mapped to snacks terminal in 60_snacks.lua
nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>',   'Terminal (vertical)')

-- v: Visits ==================================================================
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')

-- w: Write / Session =========================================================
-- local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'
--
-- nmap_leader('wd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Session delete')
-- nmap_leader('wn', '<Cmd>lua ' .. session_new .. '<CR>',         'Session new')
-- nmap_leader('wr', '<Cmd>lua MiniSessions.select("read")<CR>',   'Session read')
-- nmap_leader('wR', '<Cmd>lua MiniSessions.restart()<CR>',        'Session restart')
-- nmap_leader('ww', '<Cmd>lua MiniSessions.write()<CR>',          'Session write current')

-- stylua: ignore end
