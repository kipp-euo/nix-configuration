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
	},
	format_on_save = false,

	formatters = {
		stylua      = { prepend_args = { "--column-width", "80" } },
		ruff_format = { append_args  = { "--line-length", "80" } },
		nixfmt      = { prepend_args = { "--width=80" } },
		rustfmt     = { prepend_args = { "--config=max_width=80" } },
		prettier    = { prepend_args = { "--print-width", "80" } },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>mp",
	function()
		require("conform").format({ async = true, lsp_fallback = true })
	end,
	{ desc = "Format file / selection (Conform)" }
)
