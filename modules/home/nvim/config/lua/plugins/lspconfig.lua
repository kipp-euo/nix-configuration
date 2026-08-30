return {
	"neovim/nvim-lspconfig",
	config = function()
		vim.lsp.enable('bashls')
		vim.lsp.enable('clangd')
		vim.lsp.enable('cssls')
		vim.lsp.enable('docker_language_server')
		vim.lsp.enable('html')
		vim.lsp.enable('jsonls')
		vim.lsp.enable('lua_ls')
		vim.lsp.enable('marksman')
		vim.lsp.enable('nixd')
		vim.lsp.enable('pyright')
		vim.lsp.enable('rust_analyzer')
		vim.lsp.enable('systemd_ls')
		vim.lsp.enable('texlab')

		vim.lsp.config('lua_ls', { settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" }
				}
			}
		}})
	end,
}
