--[[
Herb Definition:
    herb_node = "modname:herb_node",
        -- the node to place

    node_under = "moondark:turf"

    weight = 10,
        -- random weight for growth

    min_light = 12,
    max_light = 14,
    max_altitude = 180,
    min_altitude = 20,
    min_humidity = 45,
    max_humidity = 60,
    min_heat = 30,
    max_heat = 60,
        -- all conditions needed for spawning
]]

md_herbs.register_herb({
    herb_node = "md_herbs:brawsterry_bush",
    weight = 1,
    max_light = 8,
    min_radius = 5,
    node_under = "moondark:turf",
})

md_herbs.register_herb({
    herb_node = "md_herbs:thrumberry_bush",
    weight = 1,
    min_light = 7,
    min_radius = 5,
    node_under = "moondark:turf",
    biomes = {"plains"}
})

-- md_herbs.register_herb({
--     herb_node = "moondark:grass",
--     weight = 1,
--     min_light = 9
-- })