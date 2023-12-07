md_physics = {}

local function calculate_attribute_product(player, attribute)
    -- turn meta into a table
	local a = minetest.deserialize(player:get_meta():get_string("md_physics:physics"))
	local product = 1
    -- if the attribute table is nil, return 1
	if a == nil or a[attribute] == nil then
		return product
	end

    -- otherwise, the factors table is set
    -- according to it's attribute key
	local factors = a[attribute]
	if type(factors) == "table" then
		for _, factor in pairs(factors) do -- for each factor
			product = product * factor -- multiply the product by it
		end
	end
	return product
end

function md_physics.add_physics_factor(player, attribute, id, value)
	local meta = player:get_meta()
	local a = minetest.deserialize(meta:get_string("md_physics:physics"))
	if a == nil then
		a = { [attribute] = { [id] = value } }
	elseif a[attribute] == nil then
		a[attribute] = { [id] = value }
	else
		a[attribute][id] = value
	end
	meta:set_string("md_physics:physics", minetest.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	player:set_physics_override({[attribute] = raw_value})
end

function md_physics.remove_physics_factor(player, attribute, id)
	local meta = player:get_meta()
	local a = minetest.deserialize(meta:get_string("md_physics:physics"))
	if a == nil or a[attribute] == nil then
		-- Nothing to remove
		return
	else
		a[attribute][id] = nil
	end
	meta:set_string("md_physics:physics", minetest.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	player:set_physics_override({[attribute] = raw_value})
end