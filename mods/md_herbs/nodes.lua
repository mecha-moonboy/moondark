minetest.register_node("md_herbs:brawsterry_bush", {
    description = "brawsterry bush",
    drawtype = "plantlike",
    tiles = {"(small_plant.png^[multiply:#115511ff)^(small_plant_berries.png^[multiply:#771122ff)"},

    -- Interaction
    groups = {hand = 3},
    walkable = false,
    sunlight_propagates = true,
    move_resistance = 1,
    floodable = true,
    drop = "md_herbs:brawsterry"
})