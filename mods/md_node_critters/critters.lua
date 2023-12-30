--local PL = moondark_core.pixel_lengths
--[[
    Critter:
    - [name] string
    - [critter_on_timer] function
    - [min_time] float min seconds for timer reset
    - [max_time] float max seconds for timer reset
    - [behaviors] table
        - [attracted_nodes] list
        - [repelled_nodes] list
    - [color]
    - [max_light]
    - [min_light]
    - [catch_chance]
]]

md_node_critters.register_critter({
    name = "midlight",
    min_time = 15,
    max_time = 45,
    color = "#88ffccff",
    light = 9,
    night_only = true,
    later_than = (1/24)*18.5,
    earlier_than = (1/24)*3,
    --max_light = 8,
    catch_chance = 4, -- 1 in 4 chance of catching bug when punched
})

if minetest.get_modpath("wielded_light") then
    wielded_light.register_item_light("moondark:midlight", 11, "")
end