
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




local active_effects = {}
active_effects.quick = {}
active_effects.weightless = {}
active_effects.restoration = {}


--  _   _ _   _ ____
-- | | | | | | |  _ \
-- | |_| | | | | | | |
-- |  _  | |_| | |_| |
-- |_| |_|\___/|____/

local EFFECT_TYPES = 0
for _,_ in pairs(active_effects) do
	EFFECT_TYPES = EFFECT_TYPES + 1
end

local icon_ids = {}

-- local function potions_set_hudbar(player)

-- 	if active_effects.poisoned[player] and active_effects.regenerating[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
-- 	elseif active_effects.poisoned[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
-- 	elseif active_effects.regenerating[player] then
-- 		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
-- 	else
-- 		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
-- 	end

-- end

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
	for effect_name, effect in pairs(active_effects) do
		if effect[player] then
			table.insert(active_effects, effect_name)
		end
	end

	for i=1, EFFECT_TYPES do
		local icon = icon_ids[name][i]
		local effect_name = act_eff[i]
		if effect_name == "quick" and active_effects.quick[player].is_slow then
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
	-- quick effect
    for player, vals in pairs(active_effects.quick) do
		if player:is_player() then
            active_effects.quick[player].timer = active_effects.quick[player].timer + dtime

            -- particle spawner
            if player:get_pos() then md_effects._add_spawner(player, "#11AA11") end

            if active_effects.quick[player].timer >= active_effects.quick[player].duration then
                md_physics.remove_physics_factor(player, "speed", "md_effects:quick")
                active_effects.quick[player] = nil
                meta = player:get_meta()
                meta:set_string("_is_quick", minetest.serialize(active_effects.quick[player]))
            end
            potions_set_hud(player)
        else
            active_effects.quick[player] = nil
        end
    end

	-- weightless effect
	for player, vals in pairs(active_effects.weightless) do
		if player:is_player() then
            active_effects.weightless[player].timer = active_effects.weightless[player].timer + dtime

            -- particle spawner
            if player:get_pos() then md_effects._add_spawner(player, "#110011") end

            if active_effects.weightless[player].timer >= active_effects.weightless[player].duration then
                md_physics.remove_physics_factor(player, "gravity", "md_effects:weightless")
                active_effects.weightless[player] = nil
                meta = player:get_meta()
                meta:set_string("_is_weightless", minetest.serialize(active_effects.weightless[player]))
            end
            potions_set_hud(player)
        else
            active_effects.weightless[player] = nil
        end
    end

	-- restoration effect
	for player, vals in pairs(active_effects.restoration) do
		is_player = player:is_player()
		entity = player:get_luaentity()


		active_effects.restoration[player].timer = active_effects.restoration[player].timer + dtime
		active_effects.restoration[player].heal_timer = (active_effects.restoration[player].heal_timer or 0) + dtime

		-- particle spawner
		if player:get_pos() then md_effects._add_spawner(player, "#11AA11") end

		if active_effects.restoration[player].heal_timer >= active_effects.restoration[player].step then

			if is_player then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1), {type = "set_hp", other = "restoration"})
				active_effects.restoration[player].heal_timer = 0
			elseif entity and entity.is_mob then
				entity.health = min(entity.hp_max, entity.health + 1)
				active_effects.restoration[player].heal_timer = 0
			else
				active_effects.restoration[player] = nil
			end
		end

		if active_effects.restoration[player]and active_effects.restoration[player].timer >= active_effects.restoration[player].duration then
			active_effects.restoration[player] = nil
			if is_player then
				meta = player:get_meta()
                meta:set_string("_has_restoration", minetest.serialize(active_effects.restoration[player]))
				potions_set_hud(player)
			end
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
	active_effects.quick[player] = nil
	active_effects.weightless[player] = nil
	active_effects.restoration[player] = nil
end

function md_effects._reset_player_effects(player, set_hud)
    if not player:is_player() then
		return
	end

    md_physics.remove_physics_factor(player, "speed", "md_effects:quick")
	md_physics.remove_physics_factor(player, "gravity", "md_effects:weightless")
	-- restoration: no permanent effects
end

function md_effects._save_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

    meta:set_string("_is_quick", minetest.serialize(active_effects.quick[player]))
	meta:set_string("_is_weightless", minetest.serialize(active_effects.weightless[player]))
	meta:set_string("_has_restoration", minetest.serialize(active_effects.restoration[player]))
end

function md_effects._load_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

    if minetest.deserialize(meta:get_string("_is_quick")) then
		active_effects.quick[player] = minetest.deserialize(meta:get_string("_is_quick"))
	end

	if minetest.deserialize(meta:get_string("_is_weightless")) then
		active_effects.weightless[player] = minetest.deserialize(meta:get_string("_is_weightless"))
	end

	if minetest.deserialize(meta:get_string("_has_restoration")) then
		active_effects.restoration[player] = minetest.deserialize(meta:get_string("_has_restoration"))
	end
end

-- Returns true if player has given effect
function md_effects.player_has_effect(player, effect_name)
	if not active_effects[effect_name] then
		return false
	end
	return active_effects[effect_name][player] ~= nil
end

function md_effects.player_get_effect(player, effect_name)
	if not active_effects[effect_name] or not active_effects[effect_name][player] then
		return false
	end
	return active_effects[effect_name][player]
end

function md_effects.player_clear_effect(player,effect)
	active_effects[effect][player] = nil
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
	md_effects._load_player_effects(player)
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

--         _____  __  __           _
--        | ____|/ _|/ _| ___  ___| |_
--        |  _| | |_| |_ / _ \/ __| __|
--        | |___|  _|  _|  __/ (__| |_
--        |_____|_| |_|  \___|\___|\__|
--  _____                 _   _
-- |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
-- | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
-- |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
-- |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

-- called every time the effect is added



function md_effects.give_quick_effect(player, fac, dur)
    -- if there's no meta data on the player, exit...
    if not player:get_meta() then
		return false
	end
    -- if the player is not in the list of quick entities/players
    if not active_effects.quick[player] then

        -- add the player as key and a table as value
		active_effects.quick[player] = {duration = dur, timer = 0,}
		md_physics.add_physics_factor(player, "speed", "md_effects:quick", fac)

	else -- player was on the list, so instead
        local victim = active_effects.quick[player]

		md_physics.add_physics_factor(player, "speed", "md_effects:quick", fac)
		-- decrement the duration
        victim.duration = math.max(dur, victim.duration - victim.timer)
		victim.timer = 0
		--victim.is_slow = factor < 1
    end

    -- if there is a hud to display
    if player:is_player() then
		potions_set_icons(player)
	end
end

function md_effects.give_weightless_effect(player, fac, dur)
    -- if there's no meta data on the player, exit...
    if not player:get_meta() then
		return false
	end
    -- if the player is not in the list of quick entities/players
    if not active_effects.weightless[player] then

        -- add the player as key and a table as value
		active_effects.weightless[player] = {duration = dur, timer = 0,}
		md_physics.add_physics_factor(player, "gravity", "md_effects:weightless", fac)

	else -- player was on the list, so instead
        local victim = active_effects.weightless[player]

		md_physics.add_physics_factor(player, "gravity", "md_effects:weightless", fac)
		-- decrement the duration
        victim.duration = math.max(dur, victim.duration - victim.timer)
		victim.timer = 0
		--victim.is_slow = factor < 1
    end

    -- if there is a hud to display
    if player:is_player() then
		potions_set_icons(player)
	end
end

function md_effects.give_restoration_effect(player, fac, dur)
    -- if there's no meta data on the player, exit...
    if not player:get_meta() then
		return false
	end
    -- if the player is not in the list of quick entities/players
    if not active_effects.restoration[player] then

        -- add the player as key and a table as value
		active_effects.restoration[player] = {duration = dur, timer = 0, step = fac}

	else -- player was on the list, so instead
        local victim = active_effects.restoration[player]

		-- decrement the duration
        victim.duration = math.max(dur, victim.duration - victim.timer)
		victim.timer = 0
		--victim.is_slow = factor < 1
    end

    -- if there is a hud to display
    if player:is_player() then
		potions_set_icons(player)
	end
end