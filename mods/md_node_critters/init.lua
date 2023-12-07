md_node_critters = {}
md_node_critters.path = minetest.get_modpath("md_node_critters")

dofile(md_node_critters.path .. "/api.lua")
dofile(md_node_critters.path .. "/critters.lua")
dofile(md_node_critters.path .. "/mapgen.lua")

-- get decoration IDs
local midlight = minetest.get_decoration_id("md_node_critters:midlight")
--local firefly_high = minetest.get_decoration_id("fireflies:firefly_high")

--minetest.set_gen_notify({decoration = true}, {midlight})

-- start nodetimers
minetest.register_on_generated(function(minp, maxp, blockseed)
	--local gennotify = minetest.get_mapgen_object("gennotify")
    --minetest.log("Chunk generated...")
	local poslist = {}

    local mls = minetest.find_nodes_in_area(minp, maxp, "md_node_critters:midlight")
    for k, ml_pos in ipairs(mls) do
        minetest.log("Key: " .. k .. ", pos: " .. minetest.serialize(ml_pos))
        table.insert(poslist, ml_pos)
    end
    mls = minetest.find_nodes_in_area(minp, maxp, "md_node_critters:midlight_off")
    for k, ml_pos in ipairs(mls) do
        minetest.log("Key: " .. k .. "' pos: " .. minetest.serialize(ml_pos))
        table.insert(poslist, ml_pos)
    end


	if #poslist ~= 0 then
		for i = 1, #poslist do
			local pos = poslist[i]
			minetest.get_node_timer(pos):start(0.1)
            minetest.log("Starting timer at pos: " .. minetest.serialize(pos))
		end
	end
end)