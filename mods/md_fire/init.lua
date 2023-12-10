md_fire = {}

local path = minetest.get_modpath("md_fire")

dofile(path .. "/api.lua")
dofile(path .. "/firenodes.lua")
dofile(path .. "/item_entity.lua")

md_fire.register_fire_recipe("moondark:stick", "moondark:noconut")