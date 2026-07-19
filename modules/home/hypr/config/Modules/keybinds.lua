local mainMod = "SUPER"

-- Launching programs
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(terminal, {
	float = true, pin = true,
	move = { "cursor_x-600*0.5", "cursor_y-30" },
	size = { "600", "400" },
}))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(steam))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(spotify))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(discord))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(obsidian))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(telegram))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(calculator, {
	float = true, 
	move = { "cursor_x-300*0.5", "cursor_y-400*0.5" },
	size = { "300", "400" },
}))

-- Menus
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(clipboardHistory))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(emojiSelector))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(nerdEmojiSelector))

-- Killing programs
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.kill())

-- Screen capture
hl.bind("Print", hl.dsp.exec_cmd(screenshotFullscreen))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(screenshotFullscreenSwappy))
hl.bind(mainMod .. " + Control_l", hl.dsp.exec_cmd(screenshotSelection))
hl.bind("SHIFT + " .. mainMod .. " + Control_l", hl.dsp.exec_cmd(screenshotSelectionSwappy))


-- Rest
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(hyprpicker))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + U", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(prism_launcher))
hl.bind(mainMod .. " + G", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.tag({ tag = "game" }))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",	hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",  hl.dsp.focus({ direction = "down" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize(
	{ x = -20, y = 0, relative = true}),
{ repeating = true })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize(
	{ x = 20, y = 0, relative = true}),
{ repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize(
	{ x = 0, y = -20, relative = true}),
{ repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize(
	{ x = 0, y = 20, relative = true}),
{ repeating = true })

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key,			 hl.dsp.focus({ workspace = i}))
	hl.bind(mainMod .. " + SHIFT + " .. key,	 hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })



-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),	  { locked = true, repeating = true })
hl.bind("XF86AudioMute",		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),	 { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",	 hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),				  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),				  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),	   { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
