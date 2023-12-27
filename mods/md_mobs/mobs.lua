md_mobs.register_mob("weaver", {
    description = "weaver",

    seal_comp_1 = 0, -- inventory image overlay component 1
    seal_comp_2 = 5, -- inventory image overlay component 2

    entity = {
        initial_properties = {
            physical = true,
            --collide_with_objects = true,
            --collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
            visual = "sprite",
            textures = {
                "weaver.png"
            },
            visual_size = {x = 4, y = 4, z = 4},
            use_texture_alpha = false,
            damage_texture_modifier = "", -- begin with ^
        },
    }
})