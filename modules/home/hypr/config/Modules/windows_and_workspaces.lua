hl.window_rule({
	name  = "suppress-maximize-events",
	match = { class = ".*" },

	-- suppress_event = "maximize fullscreen",
	suppress_event = "maximize",
})

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name  = "fix-xwayland-drags",
	match = {
		class	  = "^$",
		title	  = "^$",
		xwayland   = true,
		float	  = true,
		fullscreen = false,
		pin		= false,
	},

	no_focus = true,
})

hl.window_rule({
	name  = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move  = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	name  = "spotify-open",
	match = { class = "spotify" },

	float = true,
	pin = true,
	size = { "800", "600" },
	move = { "cursor_x-(window_w*0.5)", "cursor_y-(window_h*0.5)" },
})

hl.window_rule({
	name = "pwvucontrol-menu",
	match = { class = "com.saivert.pwvucontrol" },

	float = true,
	pin = true,
	size = { "800", "300" },
	move = { "monitor_w*0.95-800", "monitor_h*0.05" },
})

hl.window_rule({
	name = "games",
	match = {
		tag = "game",
	},

	immediate = true,
	allows_input = true,
	rounding = 0,
	border_size = 0,
	render_unfocused = false,
	no_anim = true,
	no_blur = true,
	no_dim = true,
	no_shadow = true,
	opaque = true,
	decorate = false,
})

hl.window_rule({
	name = "Picture in picture firefox",
	match = {
		initial_class = "firefox", initial_title = "Картинка в картинке",
	},

	float = true,
	pin = true,
	keep_aspect_ratio = true,
	no_initial_focus = true,
	size = { 400, 225 },
})

hl.window_rule({
	name = "Picture in picture vesktop",
	match = {
		initial_class = "vesktop", initial_title = "Discord Popout",
	},

	float = true,
	pin = true,
	keep_aspect_ratio = true,
	no_initial_focus = true,
	size = { 400, 225 },
})

hl.window_rule({
	name = "Swappy pin",
	match = {
		initial_class = "swappy",
	},

	float = true,
	pin = true,
})

hl.layer_rule({
	name      = "no-anim-for-selection",
	match     = { namespace = "selection" },
	no_anim   = true,
})
