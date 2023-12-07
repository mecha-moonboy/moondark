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

function md_effects.give_effect(player, effect)

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
function md_effects.return_on_use(def)
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

        -- call the function defined on the effect definition
        --minetest.log("log", "Calling effect on_use method now...")
        def.on_use(user, def.factor, def.duration)
        -- local old_name, old_count = itemstack:get_name(), itemstack:get_count()
        itemstack = minetest.do_item_eat(0, "", itemstack, user, pointed_thing)
        -- if old_name ~= itemstack:get_name() or old_count ~= itemstack:get_count() then
        --     -- add a particle spawner
        --     md_effects.use_potion(itemstack, user, def.color)
        -- end
        return itemstack
    end
end

function md_effects.register_consumable(name, eff_def, item_def)
    --local dur = md_effects.DURATION

    local on_use = nil

    if eff_def.on_use then
        on_use = md_effects.return_on_use(eff_def)
    end

    item_def.on_use = on_use
    item_def.on_secondary_use = on_use

    minetest.register_craftitem(name, item_def)
end

--  _____  __  __           _
-- | ____|/ _|/ _| ___  ___| |_
-- |  _| | |_| |_ / _ \/ __| __|
-- | |___|  _|  _|  __/ (__| |_
-- |_____|_| |_|  \___|\___|\__|
--  ____        __ _       _ _   _
-- |  _ \  ___ / _(_)_ __ (_) |_(_) ___  _ __  ___
-- | | | |/ _ \ |_| | '_ \| | __| |/ _ \| '_ \/ __|
-- | |_| |  __/  _| | | | | | |_| | (_) | | | \__ \
-- |____/ \___|_| |_|_| |_|_|\__|_|\___/|_| |_|___/

