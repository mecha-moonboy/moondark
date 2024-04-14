md_astro = {}
md_astro.modname = minetest.get_modpath("md_astro")

local sun_moon_scale = 1

minetest.register_on_joinplayer(function(player)
	player:set_clouds({
		height = 300
	})

	player:set_sky({
		base_color = "#ff00ffff",
		type = "regular",
		clouds = true,
		sky_color = {
			day_sky = "#445588ff",
			day_horizon = "#556699ff",
			dawn_sky = "#7755aaff",
			dawn_horizon = "#ff6622ff",
			night_sky = "#040477ff",
			night_horizon = "#040499ff",
			indoors = "#111111ff",
			fog_sun_tint = "#00000000",
			fog_moon_tint = "#00000000",
			fog_tint_type = "custom"
		},
		fog = {
			fog_distance = 512,
			fog_start = 0.2,
		}
	})

	md_astro.set_player_moon(player)
	md_astro.set_player_sun(player)
end)

minetest.register_on_shutdown(function()
    md_astro.save_state()
end)


minetest.register_globalstep(function(dtime)
     -- do astro step
    md_astro.do_step()
end)

minetest.register_on_mods_loaded(function()
	md_astro.refresh_visuals()
end)

dofile(md_astro.modname .. "/api.lua")