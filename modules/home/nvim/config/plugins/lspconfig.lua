vim.lsp.enable {
	'bashls',
	'clangd',
	'cssls',
	'docker_language_server',
	'html',
	'jsonls',
	'lua_ls',
	'marksman',
	'nixd',
	'pyright',
	'rust_analyzer',
	'systemd_ls',
	'texlab',
	'jdtls',
}

vim.lsp.config('lua_ls', { settings = {
	Lua = {
		diagnostics = {
			globals = { "vim" }
		}
	}
}})
