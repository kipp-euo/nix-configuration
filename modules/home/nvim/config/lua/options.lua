vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = false
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.opt.smartindent = true
vim.opt.cursorline = true

vim.opt.clipboard = "unnamedplus"

vim.opt.termguicolors = true

vim.opt.updatetime = 400
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false, close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" } })
	end,
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

vim.opt.spell = true
vim.opt.spelllang = { "ru", "en" }
