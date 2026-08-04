local mainMod = "SUPER"
local mainModShift = "SUPER + SHIFT"


-- Terminal
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal))
hl.bind(mainModShift .. " + E", hl.dsp.exec_cmd(terminal, {
	float = true, pin = true,
	move = { "cursor_x-600*0.5", "cursor_y-30" },
	size = { "600", "400" },
}))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(calculator, {
	float = true,
	move = { "cursor_x-300*0.5", "cursor_y-400*0.5" },
	size = { "300", "400" },
}))
hl.bind(mainModShift .. " + B", hl.dsp.exec_cmd(resourceMonitor))


-- Screen capture
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(hyprpicker))

hl.bind("Print", hl.dsp.exec_cmd(screenshotFullscreen))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(screenshotFullscreenSwappy))

hl.bind(mainMod .. " + Control_l", hl.dsp.exec_cmd(screenshotSelection))
hl.bind("SHIFT + " .. mainMod .. " + Control_l", hl.dsp.exec_cmd(screenshotSelectionSwappy))


-- Dmenu
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd(clipboardHistory))
hl.bind(mainModShift .. " + Z", hl.dsp.exec_raw(zalgoText))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(emojiSelector))
hl.bind(mainModShift .. " + R", hl.dsp.exec_cmd(nerdEmojiSelector))


-- Apps
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(steam))
hl.bind(mainModShift .. " + S", hl.dsp.exec_cmd(spotify))
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(discord))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(obsidian))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(telegram))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(prism_launcher))


-- Killing programs
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainModShift .. " + C", hl.dsp.window.kill())


-- Rest
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainModShift .. " + F", function ()
	local focused_window = hl.get_active_window()
	if focused_window == nil then
		return
	end
	local focused_pid = focused_window.pid

	local handle = io.popen("gamemoded --status=" .. focused_pid, "r")
	local gamemode_status = handle:read("*l")
	handle:close()

	local gamemode_enabled = string.find(gamemode_status, "gamemode is active and [" .. focused_pid .. "] registered", 1, true) ~= nil

	local has_game_tag = false
	if focused_window.tags ~= nil then
		for _, tag in ipairs(focused_window.tags) do
			if tag == "game" then
				has_game_tag = true
				break
			end
		end
	end
	-- Prevents desync
	if gamemode_enabled == has_game_tag then
		hl.exec_cmd("gamemoded --request=" .. focused_pid)
	end
	hl.dispatch(hl.dsp.window.tag({ tag = "game" }))
end)

hl.bind(mainMod .. " + G", hl.dsp.layout("togglesplit"))
hl.bind(mainModShift .. " + G", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Move focus with mainMod + arrow keys
hl.bind(mainModShift .. " + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true}),{ repeating = true })
hl.bind(mainModShift .. " + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true}),{ repeating = true })
hl.bind(mainModShift .. " + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true}),{ repeating = true })
hl.bind(mainModShift .. " + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true}),{ repeating = true })

----------------------------------------------------------------------------------------------------------------

-- Default binds
hl.bind(mainMod .. " + H",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K",	hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J",  hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key,			 hl.dsp.focus({ workspace = i}))
	hl.bind(mainModShift .. " + " .. key,	 hl.dsp.window.move({ workspace = i }))
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
