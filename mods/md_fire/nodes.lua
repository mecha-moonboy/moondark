-- Embers block
-- if exposed to air or ash, chance to turn to ash and faster timer
-- if not exposed to air, slower timer, but will turn to charcoal instead.
minetest.register_node("md_fire:ember", {
    description = "embers",
    drawtype = "normal",
    tiles = {"embers.png"},
    groups = {granular = 1, falling_node = 1},
    drop = "md_fire:ash",
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(5)
    end,
    on_timer = function(pos, elapsed)
        -- choose a burnable block to turn into ember
        local rand_node = moondark_core.random_pos_around_pos(pos)
        --minetest.log("What is output of get_node: " .. dump(minetest.get_node(rand_node)))
        if minetest.get_node_group(minetest.get_node(rand_node).name, "flammable") > 1 then
            minetest.set_node(rand_node, {name = "md_fire:ember"})
            minetest.get_node_timer(rand_node):start(5) -- adjust timer later
        end

        if math.random(1, 3) == 1 then
            -- check if exposed to air or ash
            local oxy_nodes = moondark_core.get_surrounding_nodes_of_group(pos, "breathable")
            -- if it is, turn this node to ash
            if #oxy_nodes ~= 0 then -- there was enough air for ash
                minetest.set_node(pos, {name = "md_fire:ash"})
                return false
            else -- there was not enough air for ash
                -- turn to charcoal
                minetest.set_node(pos, {name = "md_fire:charcoal"})
                return false
            end
        end
        return true
    end
})

minetest.register_node("md_fire:ash", {
    description = "ash",
    drawtype = "normal",
    tiles = {"ash.png"},
    groups = {granular = 1, falling_node = 1},
})

minetest.register_node("md_fire:charcoal", {
    description = "charcoal",
    drawtype = "normal",
    tiles = {"charcoal.png"},
    groups = {granular = 2, falling_node = 1},
})