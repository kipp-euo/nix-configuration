require("telescope").setup({
	defaults = {
		-- Default configuration for telescope goes here:
		-- config_key = value,
		mappings = {
			i = {
				-- map actions.which_key to <C-h> (default: <C-/>)
				-- actions.which_key shows the mappings for your picker,
				-- e.g. git_{create, delete, ...}_branch for the git_branches picker
				-- ["<C-h>"] = "which_key"
			},
		},
		border = true,
		borderchars = {
			prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			preview = { "─", "│", "─", "│", "┌", "┐", "┘", "┘" },
		},
	},
	pickers = {
		-- Default configuration for builtin pickers goes here:
		-- picker_name = {
		--   picker_config_key = value,
		--   ...
		-- }
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
	},
	extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
		["ui-select"] = {
			require("telescope.themes").get_dropdown({
				{ "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				prompt = {
					"─",
					"│",
					" ",
					"│",
					"┌",
					"┐",
					"│",
					"│",
				},
				results = {
					"─",
					"│",
					"─",
					"│",
					"├",
					"┤",
					"┘",
					"└",
				},
				preview = {
					"─",
					"│",
					"─",
					"│",
					"┌",
					"┐",
					"┘",
					"└",
				},
			}),
		},
	},
})
require("telescope").load_extension("ui-select")

local function current_dir()
	if vim.bo.filetype == "oil" then
		return require("oil").get_current_dir()
	end
end

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ cwd = current_dir() })
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", function()
	builtin.live_grep({ cwd = current_dir() })
end, { desc = "Telescope live grep" })
vim.keymap.set(
	"n",
	"<leader>fb",
	builtin.buffers,
	{ desc = "Telescope buffers" }
)
vim.keymap.set(
	"n",
	"<leader>fh",
	builtin.help_tags,
	{ desc = "Telescope help tags" }
)
