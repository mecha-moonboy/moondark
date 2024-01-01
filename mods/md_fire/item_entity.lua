-- mods/default/item_entity.lua

local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	set_item = function(self, itemstring)
		builtin_item.set_item(self, itemstring)


		local stack = ItemStack(itemstring)
		local itemdef = minetest.registered_items[stack:get_name()]
		self.itemstack = stack
		if itemdef and itemdef.groups.flammable ~= 0 then
			self.flammable = itemdef.groups.flammable
			self.heat_timer = 0
		end
	end,

	heat = function(self, node_name)
		local p = self.object:get_pos()
		local fire_level = minetest.get_node_group(node_name, "fire")
		if fire_level >= self.flammable then
			local output = md_fire.get_recipe_output(self.itemstack:get_name())
			minetest.add_item(p, ItemStack(output))
			self.object:remove() -- edit to cook item instead of removing it
		else

		end

	end,

	on_step = function(self, dtime, ...)
		builtin_item.on_step(self, dtime, ...)
		--minetest.log("Calling on_step for an item")
		-- has the flammable property
		if self.flammable then
			-- flammable, check for igniters every 10 s
			self.heat_timer = (self.heat_timer or 0) + dtime
			if self.heat_timer > 10 then
				self.heat_timer = 0
				local pos = self.object:get_pos()
				if pos == nil then
					return -- object already deleted
				end

				local node = minetest.get_node_or_nil(pos)
				if not node then
					return
				end
				if node then
					--minetest.log("Current node is ".. node.name)
					if minetest.get_node_group(node.name, "fire") ~= 0 then
						self.heat(self, node.name)
					end
				end
			end
		end
	end,
}

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, { __index = builtin_item })
minetest.register_entity(":__builtin:item", item)
