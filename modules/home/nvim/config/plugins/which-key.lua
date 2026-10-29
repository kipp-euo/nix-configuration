vim.o.timeout = true
vim.o.timeoutlen = 500

local wk = require("which-key")

wk.setup({
	preset = "classic",	-- Visual style layout: "classic", "modern", or "helix"
	win = {
		border = "single",	  -- Panel border: "none", "single", "double", "shadow"
	},
	icons = {
		mappings = true,	    -- Set to false if you do not use a Nerd Font
	},
})
