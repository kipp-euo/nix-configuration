vim.opt.updatetime = 400
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, { focusable = false, close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" } })
	end,
})
require('blink.cmp').setup({
	keymap = {
		preset = 'default',
		['<Tab>'] = { 'accept', 'fallback' },
	},
	appearance = {
		nerd_font_variant = 'mono'
	},
	completion = {
		accept = { auto_brackets = { enabled = false }, },
		documentation = { auto_show = true, auto_show_delay_ms = 500 },
		ghost_text = { enabled = true },
		menu = {
			draw = {
				components = {
					kind_icon = {
						text = function(ctx)
							local icon = ctx.kind_icon
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr ~= "" then
									icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							local highlight = "BlinkCmpKind" .. ctx.kind
							if ctx.item.source_name == "LSP" then
								local color_item = require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr_hl_group then
									highlight = color_item.abbr_hl_group
								end
							end
							return highlight
						end,
					},
				}
			}
		}
	},
	cmdline = {
		enabled = true,
		keymap = { preset = 'inherit' },
		completion = { menu = { auto_show = true } },
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' },
	},
	fuzzy = { implementation = "prefer_rust_with_warning" }
})
