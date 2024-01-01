md_fire = {}

local path = minetest.get_modpath("md_fire")

dofile(path .. "/api.lua")
dofile(path .. "/firenodes.lua")
dofile(path .. "/tools.lua")
dofile(path .. "/nodes.lua")
dofile(path .. "/recipes.lua")
dofile(path .. "/item_entity.lua")

md_fire.register_fire_recipe("moondark:stick", {min_heat = 1, output = "moondark:noconut"})
md_fire.register_fire_recipe("moondark:stick", {min_heat = 2, output = "md_herbs:brawsterry"})
minetest.register_on_mods_loaded(function()
end)
md_fire.register_flammable_item("moondark:lowan_log", {
    flammable = 2,
    burn_chance = 12,
    after_burned = "md_fire:ember"})
md_fire.register_flammable_item("moondark:lowan_wood", {
    flammable = 2,
    burn_chance = 10,
    after_burned = "md_fire:ember"})
md_fire.register_flammable_item("moondark:lowan_leaves", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "md_fire:ash_dust"})

md_fire.register_flammable_item("moondark:malpa_log", {
    flammable = 2,
    burn_chance = 10,
    after_burned = "md_fire:ember"})
md_fire.register_flammable_item("moondark:malpa_wood", {
    flammable = 2,
    burn_chance = 6,
    after_burned = "md_fire:ember"})
md_fire.register_flammable_item("moondark:malpa_leaves", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "md_fire:ash_dust"})

md_fire.register_flammable_item("moondark:stick", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "air"})
md_fire.register_flammable_item("moondark:grass", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "air"})
md_fire.register_flammable_item("moondark:driftwood", {
    flammable = 2,
    burn_chance = 2,
    after_burned = "md_fire:ash_dust"
})
-- md_fire.register_flammable_item("md_fire:charcoal", {
--     flammable = 2,
--     burn_chance = 30,
--     after_burned = "md_fire:"
-- })

md_fire.register_breathable_node("moondark:grass", 1)
md_fire.register_breathable_node("md_fire:fire_1", 1)
md_fire.register_breathable_node("md_fire:fire_2", 1)
md_fire.register_breathable_node("md_fire:ash", 1)

minetest.override_item("air", {groups = {breathable = 1}})

-- md_fire.register_breathable_node("group:leaves", 1)

