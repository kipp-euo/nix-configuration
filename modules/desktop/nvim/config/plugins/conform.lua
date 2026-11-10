require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		lua = { "stylua" },
		markdown = { "prettier" },
		nix = { "nixfmt" },
		python = { "ruff_format" },
		rust = { "rustfmt" },
		scss = { "prettier" },
		sh = { "shfmt" },
	},
	format_on_save = false,

	formatters = {
		["clang-format"] = {
			prepend_args = {
				"--style={"
					.. "BasedOnStyle: LLVM, "
					.. "ColumnLimit: 80, "
					.. "IndentWidth: 4, "
					.. "TabWidth: 4, "
					.. "UseTab: ForIndentation, "
					.. "AccessModifierOffset: -4, "
					.. "AlignAfterOpenBracket: false, "
					.. "AlignTrailingComments: false, "
					.. "BreakBeforeBraces: Attach, "
					.. "DerivePointerAlignment: false, "
					.. "PenaltyBreakComment: 0, "
					.. "PointerAlignment: Left, "
					.. "InsertBraces: true, "
				.. "}",
			},
		},
		stylua = { prepend_args = { "--column-width", "80" } },
		ruff_format = { append_args = { "--line-length", "90" } },
		nixfmt = { prepend_args = { "--width=80" } },
		rustfmt = { prepend_args = { "--config=max_width=80" } },
		prettier = { prepend_args = { "--print-width", "80" } },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format file / selection (Conform)" })
