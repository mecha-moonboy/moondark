md_fire = {}

local path = minetest.get_modpath("md_fire")

dofile(path .. "/api.lua")
dofile(path .. "/firenodes.lua")
dofile(path .. "/tools.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/recipes.lua")
dofile(path .. "/item_entity.lua")

--md_fire.register_fire_recipe("moondark:stick", "moondark:noconut")
minetest.register_on_mods_loaded(function()
end)
md_fire.register_flammable_item("moondark:lowan_log", 2)
md_fire.register_flammable_item("moondark:lowan_wood", 2)
md_fire.register_flammable_item("moondark:lowan_leaves", 1)

md_fire.register_flammable_item("moondark:malpa_log", 3)
md_fire.register_flammable_item("moondark:malpa_wood", 2)
md_fire.register_flammable_item("moondark:malpa_leaves", 1)

md_fire.register_flammable_item("moondark:stick", 1)
md_fire.register_flammable_item("moondark:grass", 1)
md_fire.register_flammable_item("moondark:driftwood", 2)

md_fire.register_breathable_node("moondark:grass", 1)
md_fire.register_breathable_node("md_fire:fire_1", 1)
md_fire.register_breathable_node("md_fire:fire_2", 1)

minetest.override_item("air", {groups = {breathable = 1}})

-- md_fire.register_breathable_node("group:leaves", 1)

