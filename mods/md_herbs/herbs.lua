md_herbs.register_herb({
    -- the node to place
    herb_node = "md_herbs:brawsterry_bush",
    weight = 10,
    -- all conditions needed for spawning
    light = 12,
    altitude_max = 180,
    altitude_min = 20,
    min_humidity = 45,
    max_humidity = 60,
    min_heat = 30,
    max_heat = 60,
    --node_under = "moondark:turf",
})

md_herbs.register_herb({
    -- the node to place
    herb_node = "moondark:grass",
    weight = 10,
    -- all conditions needed for spawning
    min_light = 7,
    altitude_max = 180,
    altitude_min = 20,
    min_humidity = 45,
    max_humidity = 60,
    min_heat = 20,
    max_heat = 80,
    --node_under = "moondark:turf",
})