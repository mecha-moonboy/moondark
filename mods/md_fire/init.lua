md_fire = {}

local path = minetest.get_modpath("md_fire")

dofile(path .. "/api.lua")
dofile(path .. "/firenodes.lua")
dofile(path .. "/item_entity.lua")

--md_fire.register_fire_recipe("moondark:stick", "moondark:noconut")

md_fire.register_flammable_item("moondark:stick", 1)
md_fire.register_flammable_item("moondark:lowan_wood", 2)