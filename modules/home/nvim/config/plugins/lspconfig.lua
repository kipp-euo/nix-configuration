vim.lsp.enable({
	"basedpyright",
	"bashls",
	"clangd",
	"cssls",
	"docker_language_server",
	"html",
	"jdtls",
	"jsonls",
	"lua_ls",
	"marksman",
	"nixd",
	"ruff",
	"rust_analyzer",
	"systemd_ls",
	"texlab",
})
vim.lsp.config(
	"*",
	{ capabilities = require("blink.cmp").get_lsp_capabilities() }
)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local function map(mode, lhs, fn, desc)
			vim.keymap.set(
				mode,
				lhs,
				fn,
				{ buffer = ev.buf, desc = "LSP: " .. desc }
			)
		end
		local tb = require("telescope.builtin")
		map("n", "grd", tb.lsp_definitions, "definition")
		map("n", "grr", tb.lsp_references, "references")
		map("n", "gri", tb.lsp_implementations, "implementation")
		map("n", "gO", tb.lsp_document_symbols, "document symbols (outline)")
		map("n", "<leader>fs", tb.lsp_dynamic_workspace_symbols, "workspace symbols")
		map("n", "<leader>fd", function()
			tb.diagnostics({ bufnr = 0 })
		end, "buffer diagnostics")
		map("n", "<leader>fD", tb.diagnostics, "workspace diagnostics")
		map("n", "<leader>th", function()
			local on = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
			vim.lsp.inlay_hint.enable(not on, { bufnr = ev.buf })
		end, "toggle inlay hints")
	end,
})

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})

vim.lsp.config("clangd", {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"--header-insertion=iwyu",
	},
	init_options = { fallbackFlags = { "-std=c++20" } },
})

vim.lsp.config("basedpyright", {
	settings = {
		basedpyright = {
			analysis = {
				diagnosticSeverityOverrides = {
					reportAny = "none",
					reportUnknownVariableType = "none",
					reportUnknownParameterType = "none",
					reportUnknownArgumentType = "none",
					reportUnknownLambdaParamType = "none",
					reportUnknownMemberType = "none",
					reportExplicitAny = "none",
					reportUnusedCallResult = "none",
				},
			},
		},
	},
})

vim.lsp.config("ruff", {
	on_attach = function(client)
		client.server_capabilities.hoverProvider = false
	end,
})

local flake = string.format('(builtins.getFlake "%s")', vim.g.nix_config_dir)
local nixos_opts =
	string.format('%s.nixosConfigurations."%s".options', flake, vim.g.nix_host)

vim.lsp.config("nixd", {
	settings = {
		nixd = {
			nixpkgs = {
				expr = string.format("import %s.inputs.nixpkgs { }", flake),
			},
			formatting = {
				command = { "nixfmt" },
			},
			options = {
				nixos = {
					expr = nixos_opts,
				},
				home_manager = {
					expr = nixos_opts
						.. ".home-manager.users.type.getSubOptions []",
				},
			},
			diagnostic = {
				suppress = { "sema-extra-with" }, -- чтобы не ныл на `with pkgs;`
			},
		},
	},
})
