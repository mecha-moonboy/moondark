minetest.handle_node_drops = function(pos, drops, digger)
	-- Add dropped items to object's inventory
	local inv = digger and digger:get_inventory()
	local give_item
	if inv then -- inventory is valid
		give_item = function(item)
			return inv:add_item("main", item)
		end
	else -- there is no digger
		give_item = function(item)
			-- itemstring to ItemStack for left:is_empty()
			return ItemStack(item)
		end
	end

	-- for each entry in the drop table
	for _, dropped_item in pairs(drops) do
		local left = give_item(dropped_item) -- attempt to add to inventory,
		if not left:is_empty() then -- if items remain
			-- randomize drop position
			local p = pos:offset(math.random()/2-0.25, math.random()/2-0.25, math.random()/2-0.25)
			-- add drop
			minetest.add_item(p, left)
		end
	end
end


-- DEBUG
function moondark_core.log(message, channel)
	if not moondark_core.DEBUG then
		return
	end

	if channel then
		minetest.log(channel, message)
	else
		minetest.log(message)
	end
end

-- Node Operations

-- check if any of the 6 adjacent nodes are of a group and return a list
function moondark_core.get_surrounding_nodes_of_group(pos, group)
	local pos_list = {
		pos:offset(0, 1, 0), -- up
		pos:offset(0, -1, 0), -- down
		pos:offset(0, 0, 1), -- front
		pos:offset(0, 0, -1), -- back
		pos:offset(1, 0, 0), -- east
		pos:offset(-1, 0, 0), -- west
	}
	local ret_list = {}
	for _, pos in ipairs(pos_list) do
		if minetest.get_node_group(minetest.get_node(pos).name, group) ~= 0 then
			table.insert(ret_list, pos)
		end
	end

	return ret_list
end

-- choose any of 6 positions around another position
function moondark_core.random_pos_around_pos(pos)
	local pos_list = {
		pos:offset(0, 1, 0), -- up
		pos:offset(0, -1, 0), -- down
		pos:offset(0, 0, 1), -- front
		pos:offset(0, 0, -1), -- back
		pos:offset(1, 0, 0), -- east
		pos:offset(-1, 0, 0), -- west
	}

	return pos_list[math.random(1, #pos_list)]
end

function moondark_core.simple_destroy_node(pos, toolname)
	local node = minetest.get_node(pos)
	local drops = minetest.get_node_drops(node, toolname)
	minetest.handle_node_drops(pos, drops)
	minetest.remove_node(pos)
end

-- attempt to eat a held item
function moondark_core.attempt_eat()

end

-- Tree Functions
function moondark_core.is_leaves(pos)
    return (minetest.get_item_group(minetest.get_node(pos).name, "leaves") > 0)
end

function moondark_core.start_decay(pos)
    if minetest.find_node_near(pos, 3, "group:log") then
        return
    end

	moondark_core.simple_destroy_node(pos, "sword")

	local new_pos = minetest.find_node_near(pos, 2, "group:leaves", false)
	while new_pos do
		--minetest.get_node_timer(new_pos):start(math.random(30, 90))
		moondark_core.start_decay(new_pos)
		moondark_core.simple_destroy_node(new_pos, "sword")
		new_pos = minetest.find_node_near(pos, 2, "group:leaves", false)
	end

end

-- chance of dropping an item, chance is better higher, else it interferes a lot with breaking normally
function moondark_core.pummel_attempt_drop(pos, clicker, dropped_item, chance, tool_group)
	if not minetest.is_player(clicker) then
		return
	end

    -- Item is in given tool group
	local item = clicker:get_wielded_item()
	local itemname = item:get_name()
	if minetest.get_item_group(itemname, tool_group) > 0 then
		if math.random(1, chance) == 1 then

			minetest.add_item(pos:offset(0, 1 ,0), dropped_item)
            minetest.remove_node(pos)
            item:add_wear_by_uses(20) -- fix this
		end
		return item
	end
end


function moondark_core.sapling_on_place(itemstack, placer, pointed_thing, sapling_name, minp_relative, maxp_relative, interval)
	-- Position of sapling
	local pos = pointed_thing.under
	local node = minetest.get_node_or_nil(pos)
	local pdef = node and minetest.registered_nodes[node.name]

	if pdef and pdef.on_rightclick and -- node definition has an on_rightclick function defined
			not (placer and placer:is_player() and -- placer is player
			placer:get_player_control().sneak) then -- placer is sneaking
		return pdef.on_rightclick(pos, node, placer, itemstack, pointed_thing) -- call the rcl function on the node
	end

	if not pdef or not pdef.buildable_to then -- if the node is nil or not buildable_to,
		pos = pointed_thing.above -- above,
		node = minetest.get_node_or_nil(pos) -- get the node,
		pdef = node and minetest.registered_nodes[node.name]
		if not pdef or not pdef.buildable_to then -- if this node is also nil or not buildable_to,
			return itemstack -- do nothing
		end
	end

	local player_name = placer and placer:get_player_name() or ""
	-- Check sapling position for protection
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return itemstack -- do nothing
	end
	-- Check tree volume for protection
	if minetest.is_area_protected(
			vector.add(pos, minp_relative),
			vector.add(pos, maxp_relative),
			player_name,
			interval) then
		minetest.record_protection_violation(pos, player_name)

		return itemstack -- do nothing
	end

	--default.log_player_action(placer, "places node", sapling_name, "at", pos)

	local take_item = not minetest.is_creative_enabled(player_name) -- whether to remove an item from the inventory stack
	local newnode = {name = sapling_name}
	local ndef = minetest.registered_nodes[sapling_name] -- create a new node def from the sapling name
	minetest.set_node(pos, newnode)

	-- Run callback
	if ndef and ndef.after_place_node then
		-- Deepcopy place_to and pointed_thing because callback can modify it
		if ndef.after_place_node(table.copy(pos), placer,
				itemstack, table.copy(pointed_thing)) then
			take_item = false -- don't take an item
		end
	end

	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		if callback(table.copy(pos), table.copy(newnode),
				placer, table.copy(node or {}),
				itemstack, table.copy(pointed_thing)) then
			take_item = false -- don't take an item
		end
	end

	if take_item then
		itemstack:take_item()
	end

	return itemstack
end

-- whether a plant can grow at a particular location
function moondark_core.can_grow(pos)
	local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not node_under then -- no node? o_O
		return false -- nope
	end
	if minetest.get_item_group(node_under.name, "soil") == 0 then -- no soil? o_O
		return false -- nope
	end
	local light_level = minetest.get_node_light(pos)
	if not light_level or light_level < 7 then -- no light? o_O
		return false -- nope
	end
	return true -- ok, can grow now, yes
end

function moondark_core.grow_sapling(pos)
	if not moondark_core.can_grow(pos) then
		--minetest.log("log", "couldn't grow tree")
		-- try again 5 min later
		minetest.get_node_timer(pos):start(3)
		return
	end

	local node = minetest.get_node(pos)
	if node.name == "moondark:lowan_seedling" then
		moondark_core.grow_new_lowan_tree(pos)
	end
end

function moondark_core.grow_new_lowan_tree(pos)
	local path = moondark_core.path ..
		"/schematics/lowan_tree.mts"
	minetest.place_schematic({x = pos.x - 6, y = pos.y - 2, z = pos.z - 6},
		path, "random", nil, false)
end

moondark_core.pixel_lengths = {
	px_1_8 = 1.0/8.0,
	px_2_8 = 1.0/4.0,
	px_4_8 = 1.0/2.0,
}