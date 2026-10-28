require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		nix = { "nixfmt" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		json = { "prettier" },
		jsonc = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		markdown = { "prettier" },
		tex = { "latexindent" },
	},
	format_on_save = false,
})

vim.keymap.set({ "n", "v" }, "<leader>mp",
	function()
		require("conform").format({ async = true, lsp_fallback = true })
	end,
	{ desc = "Format file / selection (Conform)" }
)
