-- Moondark
-- Lore based adventure game

local S = minetest.get_translator("moondark")

moondark_core = {}

moondark_core.DEBUG = true
moondark_core.LIGHT_MAX = 14
moondark_core.get_translator = S

minetest.register_on_joinplayer(function(player)
	-- Set formspec prepend
	-- local formspec = [[
	-- 		bgcolor[#080808BB;true]
	-- 		listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF] ]]
	-- local name = player:get_player_name()
	-- local info = minetest.get_player_information(name)
	-- if info.formspec_version > 1 then
	-- 	formspec = formspec .. "background9[5,5;1,1;gui_formbg.png;true;10]"
	-- else
	-- 	formspec = formspec .. "background[5,5;1,1;gui_formbg.png;true]"
	-- end
	-- player:set_formspec_prepend(formspec)

	-- Set hotbar textures
	player:hud_set_hotbar_image("hotbar_1.png^[multiply:#552205ff")
	player:hud_set_hotbar_selected_image("planks.png^[multiply:#653215ff")

	--minetest.log("log", minetest.serialize(player:hud_get(id)))
	minetest.hud_replace_builtin("health", {
		hud_elem_type = "statbar",
		position = {x=0.005, y=0.95},
		name = "health",
		scale = {x = 1, y = 1},
		text = "heart.png",
		number = 10,
		item = 20,
		direction = 3,
		alignment = {x=0, y=0},
		size = {x=32, y=32},
	})
	minetest.hud_replace_builtin("breath", {
		hud_elem_type = "statbar",
		position = {x=0.99, y=0.95},
		name = "breath",
		scale = {x = 1, y = 1},
		text = "bubble.png",
		number = 10,
		item = 20,
		direction = 3,
		alignment = {x=0, y=0},
		offset = {x=-24,y=0},
		size = {x=32, y=32},
	})
end)

moondark_core.path = minetest.get_modpath("moondark")

dofile(moondark_core.path.."/api.lua")
dofile(moondark_core.path.."/nodes.lua")
dofile(moondark_core.path.."/mapgen.lua")
dofile(moondark_core.path.."/abms.lua")
dofile(moondark_core.path.."/tools.lua")
dofile(moondark_core.path.."/craftitems.lua")
dofile(moondark_core.path.."/crafting.lua")