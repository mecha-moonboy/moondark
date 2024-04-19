local random = math.random

local function table_contains(tbl, val)
	for _, v in pairs(tbl) do
		if v == val then
			return true
		end
	end
	return false
end

-- Mob Spawns --

creatura.register_abm_spawn("md_fauna:whale", {
    --interval = 1,
    chance = 50000,
    min_height = -20,
	max_height = -2,
	min_group = 2,
	max_group = 3,
    nodes = {"group:water"},
    neighbors = {"sand", "stone", "group:water"},
    --biomes = {"moondark:ocean"}
})

-- Spawner Decoration --
minetest.register_node("md_fauna:spawner", {
	description = "???",
	drawtype = "airlike",
	walkable = false,
    floodable = false,
	pointable = true,
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand = 1, not_in_creative_inventory = 1}
})

minetest.register_decoration({
	name = "md_fauna:world_gen_spawning",
	deco_type = "simple",
	place_on = {"stone", "sand", "turf", },
	sidelen = 1,
	fill_ratio = 0.0001, -- One node per chunk
	decoration = "md_fauna:spawner"
})

minetest.register_decoration({
	name = "md_fauna:world_gen_water_spawning",
	deco_type = "simple",
	place_on = {"group:water"},
    --neighbors = {"group:water"},
    flags = "force_placement",
	sidelen = 1,
	fill_ratio = 0.0001, -- One node per chunk
	decoration = "md_fauna:spawner"
})

-- Spawn ABM --

local function do_on_spawn(pos, obj)
	local name = obj and obj:get_luaentity().name
	if not name then return end
	local spawn_functions = creatura.registered_on_spawns[name] or {}

	if #spawn_functions > 0 then
		for _, func in ipairs(spawn_functions) do
			func(obj:get_luaentity(), pos)
			if not obj:get_yaw() then break end
		end
	end
end

minetest.register_abm({
	label = "[md_fauna] World Gen Spawning",
	nodenames = {"md_fauna:spawner"},
	interval = 10, -- TODO: Set this to 1 if world is singleplayer and just started
	chance = 16,

	action = function(pos, _, active_object_count)
		minetest.remove_node(pos)

		if active_object_count > 4 then return end

		local spawnable_mobs = {}

		local current_biome = minetest.get_biome_name(minetest.get_biome_data(pos).biome)

		local spawn_definitions = creatura.registered_mob_spawns

		for mob, def in pairs(spawn_definitions) do
			if mob:match("^md_fauna:")
			and def.biomes
			and table_contains(def.biomes, current_biome) then
				table.insert(spawnable_mobs, mob)
			end
		end

		if #spawnable_mobs > 0 then
			local mob_to_spawn = spawnable_mobs[math.random(#spawnable_mobs)]
			local spawn_definition = creatura.registered_mob_spawns[mob_to_spawn]

			local group_size = random(spawn_definition.min_group or 1, spawn_definition.max_group or 1)
			local obj

			if group_size > 1 then
				local offset
				local spawn_pos
				for _ = 1, group_size do
					offset = group_size * 0.5
					spawn_pos = creatura.get_ground_level({
						x = pos.x + random(-offset, offset),
						y = pos.y,
						z = pos.z + random(-offset, offset)
					}, 3)

					if not creatura.is_pos_moveable(spawn_pos, 0.5, 0.5) then
						spawn_pos = pos
					end

					obj = minetest.add_entity(spawn_pos, mob_to_spawn)
					do_on_spawn(spawn_pos, obj)
				end
			else
				obj = minetest.add_entity(pos, mob_to_spawn)
				do_on_spawn(pos, obj)
			end
		end
	end
})