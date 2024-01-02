creatura.register_mob("md_mobs:weaver", {
    visual_size = {x = 16, y = 16},

    max_health = 10,
    damage = 1,
    speed = 1,
    tracking_range = 12,
    despawn_after = 200,
    stepheight = 1.1,

    hitbox = {
		width = 0.15,
		height = 0.3
	},

    drops = {
		{name = "md_mobs:seal_weaver", min = 1, max = 1, chance = 1}
	},

    flee_puncher = true,

    utility_stack = {
        utility = "md_mobs:follow_player",
        get_score = 1
    }
})

creatura.register_spawn_item("md_mobs:weaver",{
    col1 = "000000",
    col2 = "005500"
})