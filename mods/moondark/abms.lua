minetest.register_abm({
    nodenames = {"moondark:stone"},
    neighbors = { "air" },
    interval = 120,
    chance = 1,
    action = function(pos, node)
        local new_pos = pos:offset(0, 1, 0)
        if minetest.get_node(new_pos).name == "air" or minetest.get_node(new_pos).name == "cave_air" then -- if node is air, place
            if not minetest.find_node_near(new_pos, 7, "moondark:rock") then
                minetest.set_node(new_pos, {name = "moondark:rock"})
            end
        end
    end,
})

-- moondark:grass
-- plants