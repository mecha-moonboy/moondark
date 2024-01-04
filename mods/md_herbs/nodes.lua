minetest.register_node("md_herbs:brawsterry_bush", {
    description = "brawsterry bush",
    drawtype = "plantlike",
    tiles = {"(small_plant.png^[multiply:#003311ff)^(small_plant_berries.png^[multiply:#770000ff)"},

    -- Interaction
    groups = {hand = 1},
    walkable = false,
    sunlight_propagates = true,
    move_resistance = 1,
    floodable = true,
    drop = "md_herbs:brawsterry"
})

minetest.register_node("md_herbs:thrumberry_bush", {
    description = "thrumberry bush",
    drawtype = "plantlike",
    tiles = {"(medium_plant.png^[multiply:#003311ff)^(medium_plant_berries.png^[multiply:#330066ff)"},

    -- Interaction
    groups = {hand = 1},
    walkable = false,
    sunlight_propagates = true,
    move_resistance = 1,
    floodable = true,
    drop = "md_herbs:thrumberry"
})