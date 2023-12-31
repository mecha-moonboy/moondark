
--[[
	How to add an effect:
	- add consumable or item with effect
	- global step
	- effect function

	- clear cache
	- reset effects
	- save effects
	- load effects
]]


md_effects.registered_effects = {}

md_effects.active_effects = {}


--  _   _ _   _ ____
-- | | | | | | |  _ \
-- | |_| | | | | | | |
-- |  _  | |_| | |_| |
-- |_| |_|\___/|____/

local EFFECT_TYPES = 0
for _,_ in pairs(md_effects.registered_effects) do
	EFFECT_TYPES = EFFECT_TYPES + 1
end

local icon_ids = {}

-- local function potions_set_hudbar(player)

-- 	if md_effects.active_effects.poisoned[player] and md_effects.active_effects.regenerating[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
-- 	elseif md_effects.active_effects.poisoned[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
-- 	elseif md_effects.active_effects.regenerating[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
-- 	else
-- 		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
-- 	end

-- end

function md_effects.register_effect(name, effect_definition)
	md_effects.registered_effects[name] = effect_definition
	md_effects.active_effects[name] = {}
end

local function potions_init_icons(player)
	local name = player:get_player_name()
	icon_ids[name] = {}
	for e=1, EFFECT_TYPES do
		local x = -52 * e - 2
		local id = player:hud_add({
			hud_elem_type = "image",
			text = "blank.png",
			position = { x = 1, y = 0 },
			offset = { x = x, y = 3 },
			scale = { x = 0.375, y = 0.375 },
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		table.insert(icon_ids[name], id)
	end
end

local function potions_set_icons(player)
	local name = player:get_player_name()
	if not icon_ids[name] then
		return
	end
	local act_eff = {}
	for effect_name, effect in pairs(md_effects.active_effects) do
		if effect[player_name] then
			table.insert(md_effects.active_effects, effect_name)
		end
	end

	for i=1, EFFECT_TYPES do
		local icon = icon_ids[name][i]
		local effect_name = act_eff[i]
		if effect_name == "quick" and md_effects.active_effects.quick[player].is_slow then
			effect_name = "slow"
		end
		if effect_name == nil then
			player:hud_change(icon, "text", "blank.png")
		else
			player:hud_change(icon, "text", "mcl_potions_effect_"..effect_name..".png^[resize:128x128")
		end
	end

end

local function potions_set_hud(player)
	--potions_set_hudbar(player)
	potions_set_icons(player)
end

--  _____  __  __           _
-- | ____|/ _|/ _| ___  ___| |_
-- |  _| | |_| |_ / _ \/ __| __|
-- | |___|  _|  _|  __/ (__| |_
-- |_____|_| |_|  \___|\___|\__|
--     ____  _
--    / ___|| |_ ___ _ __
--    \___ \| __/ _ \ '_ \
--     ___) | ||  __/ |_) |
--    |____/ \__\___| .__/
--                  |_|

local is_player, entity, meta

-- put ongoing status effect code in here
minetest.register_globalstep(function(dtime)
	for effect_name, player_list  in pairs(md_effects.active_effects) do
		--minetest.log(effect_name)
		local effect = md_effects.registered_effects[effect_name]

		for player_name, eff_inst in pairs(player_list) do
			--moondark_core.log("Effect: " .. effect_name)
			--moondark_core.log("Player: " .. player_name)
			minetest.log("Effect instance: " .. minetest.serialize(eff_inst))
			if not md_effects.active_effects[effect_name][player_name] then return end

			local player = minetest.get_player_by_name(player_name)

			-- timer for effect duration
			if not md_effects.active_effects[effect_name][player_name].timer then md_effects.active_effects[effect_name][player_name].timer = 0 end

			md_effects.active_effects[effect_name][player_name].timer = md_effects.active_effects[effect_name][player_name].timer + dtime

			-- particle spawner
			if effect.particle_color then
				if player:get_pos() then md_effects._add_spawner(player, effect.particle_color) end
			end

			-- whether the effect should end
			if md_effects.active_effects[effect_name][player_name].timer >= md_effects.active_effects[effect_name][player_name].duration then
				if effect.physics_override then
					md_physics.remove_physics_factor(player, effect.physics_override.attribute, effect.physics_override.id)
				end
				md_effects.active_effects[effect_name][player_name] = nil
				meta = player:get_meta()
				meta:set_string(effect.meta_tag, minetest.serialize(md_effects.active_effects[effect_name][player_name]))
				return
			end


			local step = md_effects.registered_effects[effect_name].step
			-- effect timer
			if step then
				if not md_effects.active_effects[effect_name][player_name] then
					md_effects.active_effects[effect_name][player_name] = {duration = effect.duration, timer = 0, timer2 = 0}
				end
				-- timer for effect step
				md_effects.active_effects[effect_name][player_name].timer2 = (md_effects.active_effects[effect_name][player_name].timer2 or 0) + dtime
				if md_effects.active_effects[effect_name][player_name].timer2 >= step then
					moondark_core.log("Executing on_step for " .. effect_name)
					effect.on_step(player)
					md_effects.active_effects[effect_name][player_name].timer2 = 0
				end
			end
			potions_set_hud(player)
		end
	end
end)

--            _____  __  __           _
--           | ____|/ _|/ _| ___  ___| |_
--           |  _| | |_| |_ / _ \/ __| __|
--           | |___|  _|  _|  __/ (__| |_
--           |_____|_| |_|  \___|\___|\__|
--  _                    _    ______
-- | |    ___   __ _  __| |  / / ___|  __ ___   _____
-- | |   / _ \ / _` |/ _` | / /\___ \ / _` \ \ / / _ \
-- | |__| (_) | (_| | (_| |/ /  ___) | (_| |\ V /  __/
-- |_____\___/ \__,_|\__,_/_/  |____/ \__,_| \_/ \___|

function md_effects._clear_cached_player_data(player)
	local player_name = player:get_player_name()
	for effect_name, player_list in pairs(md_effects.active_effects) do
		local effect = md_effects.registered_effects[effect_name]
		md_effects.active_effects[effect_name][player_name] = nil
	end
end

function md_effects._reset_player_effects(player, set_hud)
    if not player:is_player() then
		return
	end

	-- fix this here
end

function md_effects._save_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()
	local player_name = player:get_player_name()

	for effect_name, player_list in pairs(md_effects.active_effects) do
		local effect = md_effects.registered_effects[effect_name]
		if md_effects.active_effects[effect_name][player_name] then
			meta:set_string(effect.meta_tag, minetest.serialize(md_effects.active_effects[effect_name][player_name]))
		end
	end
end

function md_effects._load_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()
	local player_name = player:get_player_name()
	for effect_name, players in pairs(md_effects.active_effects) do
		local effect = md_effects.registered_effects[effect_name]
		for player, _ in pairs(players) do
			md_effects.active_effects[effect_name][player_name] = minetest.deserialize(meta:get_string(effect.meta_tag))
		end
	end
end

-- Returns true if player has given effect
function md_effects.player_has_effect(player, effect_name)
	if not md_effects.active_effects[effect_name] then
		return false
	end
	return md_effects.active_effects[effect_name][player:get_player_name()] ~= nil
end

function md_effects.player_get_effect(player, effect_name)
	if not md_effects.active_effects[effect_name] or not md_effects.active_effects[effect_name][player:get_player_name()] then
		return false
	end
	return md_effects.active_effects[effect_name][player:get_player_name()]
end

function md_effects.player_clear_effect(player, effect_name)
	md_effects.active_effects[effect_name][player:get_player_name()] = nil
	potions_set_icons(player)
end

minetest.register_on_leaveplayer( function(player)
	md_effects._save_player_effects(player)
	md_effects._clear_cached_player_data(player) -- clearout the buffer to prevent looking for a player not there
	icon_ids[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer( function(player)
	md_effects._reset_player_effects(player)
	potions_set_hud(player)
end)

minetest.register_on_joinplayer( function(player)
	md_effects._reset_player_effects(player, false) -- make sure there are no wierd holdover effects
	--md_effects._load_player_effects(player)
	potions_init_icons(player)
	-- .after required because player:hud_change doesn't work when called
	-- in same tick as player:hud_add
	-- (see <https://github.com/minetest/minetest/pull/9611>)
	-- FIXME: Remove minetest.after
	minetest.after(3, function(player)
		if player and player:is_player() then
			potions_set_hud(player)
		end
	end, player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in pairs(minetest.get_connected_players()) do
		md_effects._save_player_effects(player)
	end

end)

--  ____                               _
-- / ___| _   _ _ __  _ __   ___  _ __| |_
-- \___ \| | | | '_ \| '_ \ / _ \| '__| __|
--  ___) | |_| | |_) | |_) | (_) | |  | |_
-- |____/ \__,_| .__/| .__/ \___/|_|   \__|
--             |_|   |_|

function md_effects._use_potion(item, obj, color)
	local d = 0.1
	local pos = obj:get_pos()
	minetest.add_particlespawner({
		amount = 25,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 1,
		maxexptime = 5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end

function md_effects._add_spawner(obj, color)
	local d = 0.2
	local pos = obj:get_pos()
	minetest.add_particlespawner({
		amount = 1,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end

--     _       _     _   _____  __  __           _
--    / \   __| | __| | | ____|/ _|/ _| ___  ___| |_
--   / _ \ / _` |/ _` | |  _| | |_| |_ / _ \/ __| __|
--  / ___ \ (_| | (_| | | |___|  _|  _|  __/ (__| |_
-- /_/   \_\__,_|\__,_| |_____|_| |_|  \___|\___|\__|
--    _____                 _   _
--   |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
--   | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
--   |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
--   |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/


-- called to add effects
function md_effects.give_effect(player, effect_name, duration)
	moondark_core.log("Giving effect to player...")

	-- if there's no meta data on the player, exit...
    if not player:get_meta() then
		return false
	end

	local player_name = player:get_player_name()

	-- get the effect from registry
	local effect = md_effects.registered_effects[effect_name]

	if effect.physics_override then
		md_physics.add_physics_factor(player,
		effect.physics_override.attribute,
		effect.physics_override.id,
		effect.physics_override.factor
	)
	end

    if not md_effects.active_effects[effect_name][player_name] then
		moondark_core.log("Player did not have the effect before, now they do...")

        -- add the player as key and a table as value
		md_effects.active_effects[effect_name][player_name] = {duration = duration, timer = 0, timer2 = 0}
		if effect.start_func then
			moondark_core.log("Calling the start function of the effect...")
			effect.start_func(minetest.get_player_by_name(player_name))
		end
	else -- player was on the list, so instead
		moondark_core.log("Player did have the effect before...")

		local victim = md_effects.active_effects[effect_name][player_name]

		if effect.start_func then
			moondark_core.log("Calling the start function of the effect...")
				effect.start_func(minetest.get_player_by_name(player_name))
		end

		-- decrement the duration
        victim.duration = math.max(duration, victim.duration - victim.timer)
		victim.timer = 0
    end

    -- if there is a hud to display
    if player:is_player() then
		potions_set_icons(player)
	end
end

--------------------------------------------------------------------------

-- return the number of minutes
local function time_string(dur)
	if not dur then
		return nil
	end
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end

-- return the factor as a percentage
local function percent_string(num)

	local rem = math.floor((num-1.0)*100 + 0.1) % 5
	local out = math.floor((num-1.0)*100 + 0.1) - rem

	if (num - 1.0) < 0 then
		return out.."%"
	else
		return "+"..out.."%"
	end
end

--  _____  __  __           _
-- | ____|/ _|/ _| ___  ___| |_
-- |  _| | |_| |_ / _ \/ __| __|
-- | |___|  _|  _|  __/ (__| |_
-- |_____|_| |_|  \___|\___|\__|
--  ____            _     _             _   _
-- |  _ \ ___  __ _(_)___| |_ _ __ __ _| |_(_) ___  _ __
-- | |_) / _ \/ _` | / __| __| '__/ _` | __| |/ _ \| '_ \
-- |  _ <  __/ (_| | \__ \ |_| | | (_| | |_| | (_) | | | |
-- |_| \_\___|\__, |_|___/\__|_|  \__,_|\__|_|\___/|_| |_|
--            |___/

-- returns the on_use function for most definitions
function md_effects.return_on_use(consumable_def)
    return function (itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            if user and not user:get_player_control().sneak then
                -- is node and player not sneaking
                -- use pointed node's on_rightclick function first, if present
                local node = minetest.get_node(pointed_thing.under)
                if user and not user:get_player_control().sneak then
                    if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
                        return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
                    end
                end
            end
        elseif pointed_thing.type == "object" then -- abort if another object
            return itemstack
        end

        consumable_def.on_use(itemstack, user, pointed_thing)

        -- local old_name, old_count = itemstack:get_name(), itemstack:get_count()
        itemstack = minetest.do_item_eat(0, "", itemstack, user, pointed_thing)
        -- if old_name ~= itemstack:get_name() or old_count ~= itemstack:get_count() then
        --     -- add a particle spawner
        --     md_effects.use_potion(itemstack, user, def.color)
        -- end
        return itemstack
    end
end

function md_effects.register_consumable(name, consumable_def)

    -- local on_use = nil
    -- --local eff = md_effects.registered_effects[consumable_def.effect_name]
    -- if consumable_def then
    --     on_use = md_effects.return_on_use(consumable_def)
    -- end

    -- consumable_def.on_use = on_use
    consumable_def.on_secondary_use = consumable_def.on_use

    minetest.register_craftitem(name, consumable_def)
end


