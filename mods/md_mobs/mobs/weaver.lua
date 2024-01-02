creatura.register_mob("md_mobs:weaver", {
    visual_size = {x = 16, y = 16},
    mesh = "weaver.b3d",
    textures = {
		"weaver.png",
	},

    max_health = 10,
    damage = 1,
    speed = 5,
    tracking_range = 30,
    despawn_after = 200,
    stepheight = 1.1,

    armor_groups = {fleshy = 100},
    hitbox = {
		width = 1,
		height = 0.8
	},

    animations = {
		stand = {range = {x = 1, y = 39}, speed = 20, frame_blend = 0.3, loop = true},
		walk = {range = {x = 51, y = 69}, speed = 20, frame_blend = 0.3, loop = true},
		run = {range = {x = 81, y = 99}, speed = 45, frame_blend = 0.3, loop = true},
		eat = {range = {x = 111, y = 119}, speed = 20, frame_blend = 0.1, loop = false}
	},

    drops = {
		{name = "md_mobs:seal_weaver", min = 1, max = 1, chance = 1}
	},

    flee_puncher = true,

    utility_stack = {
        {
            utility = "md_mobs:follow_player",
            get_score = function(self)
                return 0.6, {self, creatura.get_nearby_player(self), true}
            end
        }
    },

    on_punch = creatura.basic_punch_func,

    death_func = function(self)
		if self:get_utility() ~= "md_mobs:die" then
			self:initiate_utility("md_mobs:die", self)
		end
	end,
})

creatura.register_spawn_item("md_mobs:weaver",{
    col1 = "000000",
    col2 = "005500"
})