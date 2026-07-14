hl.on("hyprland.start", function ()
	hl.exec_cmd("cliphist wipe")
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
	hl.exec_cmd(fileManager .. " --daemon")

	hl.exec_cmd(browser, { workspace = "1 silent" })
	hl.exec_cmd(steam .. " -silent", { workspace = "2 silent" })
	hl.exec_cmd(discord, { workspace = "2 silent" })
	hl.exec_cmd(spotify, { workspace = "1 silent" })
end)

hl.on("hyprland.shutdown", function()
	os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)
