minetest.override_item("", {
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {
			hand = {times={[1]=1, [2]=2, [3]=4, [4]=8, [5]=16,  }, uses=0}
		},
		damage_groups = {bludgeoning=1},
	},
})

function moondark_core.on_rake(itemstack, user, pointed_thing, uses)
	-- get the position under wherever the player clicked
	local pos_under
	if pointed_thing.type == "node" then
		pos_under = pointed_thing.under
	elseif pointed_thing.type == "object" then
		pos_under = pointed_thing.ref:get_pos()
	else
		return itemstack
	end

	local inv = user:get_inventory()

	local rad = minetest.get_item_group(itemstack:get_name(), "rake") + 1
	local ents = minetest.get_objects_in_area(pos_under:offset(-rad, -rad, -rad), pos_under:offset(rad, rad, rad))

	for _, ent in pairs(ents) do
		if ent:get_luaentity() -- yes, is lua entity
		and ent:get_luaentity().name == "__builtin:item" then -- and is item, yes, yes
			local lua_ent = ent:get_luaentity()
			local stack = ItemStack(lua_ent.itemstring)
			if inv:room_for_item("main", stack) then
				itemstack:add_wear_by_uses(uses)

				minetest.item_pickup(stack, user, pointed_thing)

				ent:remove()
			end
		end
	end
	return itemstack
end

minetest.register_tool("moondark:rake", {
	description = "wooden rake",
    inventory_image = "rake.png",
    tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			items={times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=30, maxlevel=1},
		},
		damage_groups = {bludgeoning=2},
	},
    groups = {rake = 1},
	on_use = function(itemstack, user, pointed_thing)
		return moondark_core.on_rake(itemstack, user, pointed_thing, 128)
	end
})

minetest.register_tool("moondark:bronze_rake", {
	description = "bronze rake",
    inventory_image = "bronze_rake.png",
    tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			items={times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=90, maxlevel=1},
		},
		damage_groups = {bludgeoning=3},
	},
    groups = {rake = 2},
	on_use = function(itemstack, user, pointed_thing)
		return moondark_core.on_rake(itemstack, user, pointed_thing, 256)
	end
})

minetest.register_tool("moondark:axe_stone", {
    description = "stone axe",
    inventory_image = "axe_1.png",
    tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			wooden={times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=30, maxlevel=1},
		},
		damage_groups = {shlashing=3},
	},
    groups = {axe = 1}
})

minetest.register_tool("moondark:sword_stone", {
	description = "stone machete",
	inventory_image = "machete_1.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level=0,
		groupcaps={
			fiberous={times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=30, maxlevel=1},
		},
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {sword = 1},
})

minetest.register_tool("moondark:pick_stone", {
	description = "stone pickaxe",
	inventory_image = "pick_1.png",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			stone = {times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=30, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})

minetest.register_tool("moondark:digging_stick", {
	description = "digging stick",
	inventory_image = "digging_stick.png",
    color = "#603010ff",
	tool_capabilities = {
		full_punch_interval = 1.3,
		max_drop_level=0,
		groupcaps={
			granular = {times={[1]=0.5, [2]=1.0, [3]=2.0, [4]=4.0 }, uses=5, maxlevel=1},
		},
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {shovel = 1}
})