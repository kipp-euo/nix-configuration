vim.lsp.enable {
	'basedpyright',
	'bashls',
	'clangd',
	'cssls',
	'docker_language_server',
	'html',
	'jdtls',
	'jsonls',
	'lua_ls',
	'marksman',
	'nixd',
	'rust_analyzer',
	'systemd_ls',
	'texlab',
}
-- vim.lsp.inlay_hint.enable(true)

vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

vim.lsp.config('lua_ls', { settings = {
	Lua = {
		diagnostics = {
			globals = { "vim" }
		}
	}
}})

vim.lsp.config('clangd', { cmd = {
	'clangd',
	'--background-index',
	'--clang-tidy',
	'--completion-style=detailed',
	'--function-arg-placeholders',
	'--header-insertion=iwyu'
}})

vim.lsp.config('basedpyright', { settings = { basedpyright = {
	analysis = {
		diagnosticSeverityOverrides = {
			reportAny = "none",
			reportUnknownVariableType = "none",
			reportUnknownParameterType = "none",
			reportUnknownArgumentType = "none",
			reportUnknownLambdaParamType = "none",
			reportUnknownMemberType = "none",
		},
	},
}}})
