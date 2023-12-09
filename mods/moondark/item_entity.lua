-- mods/default/item_entity.lua

local builtin_item = minetest.registered_entities["__builtin:item"]

local item = {
	set_item = function(self, itemstring)
		builtin_item.set_item(self, itemstring)


		local stack = ItemStack(itemstring)
		local itemdef = minetest.registered_items[stack:get_name()]
		if itemdef and itemdef.groups.flammable ~= 0 then
			self.flammable = itemdef.groups.flammable
		end
	end,

	heat = function(self)
		-- disappear in a smoke puff
		local p = self.object:get_pos()
		local meta = self.object:get_meta()
		local curr_heat = meta:get_int("heat")
		minetest.log("Item heat: " .. curr_heat)
		-- --local output = minetest.get_craft_result({method = "cooking", items = builtin_item.get_item(self)})
		-- self.object:remove() -- edit to cook item instead of removing it
	end,

	on_step = function(self, dtime, ...)
		builtin_item.on_step(self, dtime, ...)

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
					minetest.log("Current node is ".. node.name)
				end
			end
		end
	end,
}

-- set defined item as new __builtin:item, with the old one as fallback table
setmetatable(item, { __index = builtin_item })
minetest.register_entity(":__builtin:item", item)
