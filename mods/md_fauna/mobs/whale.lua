----------
-- Fish --
----------

creatura.register_mob("md_fauna:whale", {
	-- Engine Props
	visual_size = {x = 10, y = 10},
	meshes = {
		"md_fauna_whale.b3d",
	},
	mesh_textures = {
		{
			"md_fauna_whale_small.png",
		},
		{
			"md_fauna_whale_small.png"
		}
	},

	-- Creatura Props
    turn_rate = 0.5,
	max_health = 50,
	armor_groups = {fleshy = 150},
	damage = 0,
	max_breath = 0,
	speed = 3,
	tracking_range = 6,
	max_boids = 6,
	boid_seperation = 0.3,
	despawn_after = 200,
	max_fall = 0,
	stepheight = 1.1,
	hitbox = {
		width = 2,
		height = 2
	},
	animations = {
		swim = {range = {x = 0, y = 24}, speed = 4, frame_blend = 0.3, loop = true},
		roll = {range = {x = 25, y = 48}, speed = 4, frame_blend = 0.3, loop = true},
	},
	liquid_submergence = 10,
	liquid_drag = 1,
    max_depth = -15,

	-- Animalia Behaviors
	is_aquatic_mob = true,

	-- Animalia Props
	flee_puncher = false,
	catch_with_net = true,
	catch_with_lasso = false,

	-- Functions
	utility_stack = {
		md_fauna.mob_ai.swim_wander
	},

	activate_func = function(self)
		--animalia.initialize_api(self)
		--animalia.initialize_lasso(self)
	end,

	step_func = function(self)
		--animalia.step_timers(self)
		--animalia.do_growth(self, 60)
		--animalia.update_lasso_effects(self)
	end,

	death_func = function(self)
		if self:get_utility() ~= "md_fauna:die" then
			self:initiate_utility("md_fauna:die", self)
		end
	end,

	on_rightclick = function(self, clicker)
		-- if animalia.set_nametag(self, clicker) then
		-- 	return
		-- end
	end,

	--on_punch = animalia.punch
})

creatura.register_spawn_item("md_fauna:whale", {
	col1 = "4444ff",
	col2 = "9999ff"
})

-- animalia.alias_mob("animalia:clownfish", "animalia:tropical_fish")
-- animalia.alias_mob("animalia:blue_tang", "animalia:tropical_fish")
-- animalia.alias_mob("animalia:angelfish", "animalia:tropical_fish")