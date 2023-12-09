md_fire.register_fire_node({
    name = "fire_1",
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
    tick_length = 5,
})