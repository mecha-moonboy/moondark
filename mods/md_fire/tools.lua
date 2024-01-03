-- Tinder
minetest.register_tool("md_fire:tinder", {
	description = "tinder",
	inventory_image = "tinder.png",
	--sound = {breaks = "default_tool_breaks"},

	on_use = function(itemstack, user, pointed_thing)
		--local sound_pos = pointed_thing.above or user:get_pos()
		-- minetest.sound_play("fire_flint_and_steel",
		-- 	{pos = sound_pos, gain = 0.2, max_hear_distance = 8}, true)

        local player_name = user:get_player_name()
		if pointed_thing.type == "node" then
			local node_under = minetest.get_node(pointed_thing.under).name
			local nodedef = minetest.registered_nodes[node_under]
			if not nodedef then
				return
			end
			if minetest.is_protected(pointed_thing.under, player_name) then
				minetest.chat_send_player(player_name, "This area is protected")
				return
			end
			if math.random(1, 1) == 1 then -- adjust this later
				if nodedef.on_ignite then
					nodedef.on_ignite(pointed_thing.under, user)
				elseif minetest.get_item_group(node_under, "flammable") >= 1
						and minetest.get_node(pointed_thing.above).name == "air" then
					minetest.set_node(pointed_thing.above, {name = "md_fire:fire_1"})
				end
			end
		end
		if not minetest.is_creative_enabled(player_name) then
			-- Wear tool
			local wdef = itemstack:get_definition()
			itemstack:add_wear_by_uses(64)

			-- Tool break sound
			-- if itemstack:get_count() == 0 and wdef.sound and wdef.sound.breaks then
			-- 	minetest.sound_play(wdef.sound.breaks,
			-- 		{pos = sound_pos, gain = 0.5}, true)
			-- end
			return itemstack
		end
	end
})