mp.add_hook("on_preloaded", 10, function ()
	local audio_tracks = 0

	for _, track in ipairs(mp.get_property_native("track-list")) do
		if track.type == "audio" then
			audio_tracks = audio_tracks + 1
		end
	end

	if audio_tracks < 2 then
		mp.set_property("lavfi-complex", "")
		return
	end

	local graph = ''
	for i = 1, audio_tracks do
		graph = graph .. "[aid" .. i .. "]"
	end

	mp.set_property("lavfi-complex", graph .. "amix=inputs=" .. audio_tracks .. "[ao]")
end)
