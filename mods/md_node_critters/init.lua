md_node_critters = {}
md_node_critters.path = minetest.get_modpath("md_node_critters")

dofile(md_node_critters.path .. "/api.lua")
dofile(md_node_critters.path .. "/critters.lua")
dofile(md_node_critters.path .. "/mapgen.lua")

-- start nodetimers
minetest.register_on_generated(function(minp, maxp, blockseed)
	local poslist = {}

    local mls = minetest.find_nodes_in_area(minp, maxp, "md_node_critters:midlight")
    for k, ml_pos in ipairs(mls) do
        table.insert(poslist, ml_pos)
    end

	if #poslist ~= 0 then
		for i = 1, #poslist do
			local pos = poslist[i]
			minetest.get_node_timer(pos):start(0.1)
		end
	end
end)