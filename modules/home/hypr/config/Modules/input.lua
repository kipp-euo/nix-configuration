hl.config({
	input = {
		kb_layout  = "us, ru",
		kb_variant = "",
		kb_model   = "",
		kb_options = "grp:alt_shift_toggle, caps:escape",
		kb_rules   = "",
		
		repeat_rate = 125,
		repeat_delay = 300,
		follow_mouse = 1,
		sensitivity = 0.0,
		accel_profile = "flat",

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace"
})
