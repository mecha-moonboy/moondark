minetest.register_node("md_mobs:weaver_nest", {
    description = "weaver nest",
    tiles = {"weaver_nest.png"},
    drawtype = "nodebox",
    visual_scale = 2.0,
    node_box = {
        type = "regular",
        fixed = {
            {-1, -1, -1, 1, 1, 1},
        },
    }

    -- on timer do spawning function
})