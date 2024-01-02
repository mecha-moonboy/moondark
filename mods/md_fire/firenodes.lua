md_fire.register_fire_node({
    name = "fire_1",

    --max_heat = 1,

    heat = 1,
    light = 5,
    tiles = {
        name = "fire_1.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1,
        }
    },
    damage = 1,
    tick_length = 16,
    tick_variance = 8,
    hotter_fire = "md_fire:fire_2",
    cooler_fire = "air"
})

md_fire.register_fire_node({
    name = "fire_2",

    --max_heat = 1,

    heat = 2,
    light = 8,
    tiles = {
        name = "fire_2.png",
        animation = {
            type = "vertical_frames",
            aspect_w = 16,
            aspect_h = 16,
            length = 1,
        }
    },
    damage = 1,
    tick_length = 8,
    tick_variance = 4,
    --hotter_fire = "fire_3",
    cooler_fire = "md_fire:fire_1",
})