hl.config({
	general = {
		gaps_in  = 5,
		gaps_out = 12,
		border_size = 2,
		col = {
			active_border   = {
				colors = {color_pink, color_violet},
				angle = 90
			},
			inactive_border   = {
				colors = {color_light_violet, color_light_blue },
				angle = 90
			},
		},
		resize_on_border = false,
		allow_tearing = true,
		layout = "dwindle",
	},

	decoration = {
		rounding	= 8,
		rounding_power	= 2,

		active_opacity   = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled   = false,
		},
		blur = {
			enabled   = false,
		},
	},

	animations = {
		enabled = true,
	},

	render = {
		expand_undersized_textures = false,
		new_render_scheduling = true,
		direct_scanout = 1,
	},
})


hl.config({
	dwindle = {
		preserve_split = true,
	},
	master = {
		new_status = "master",
	},
	scrolling = {
		fullscreen_on_one_column = true,
	},
})
