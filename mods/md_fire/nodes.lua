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
        minetest.get_node_timer(pos):start(7.5)
    end,
    on_timer = function(pos, elapsed)
        -- choose a burnable block to turn into ember
        local burning_node = minetest.find_node_near(pos, 1, "group:flammable")

        -- there is a node to burn that is not charcoal
        -- replace it with it's after_burned node
        if burning_node ~= nil and
        minetest.get_node(burning_node).name ~= "md_fire:charcoal" and
        minetest.get_node_group(minetest.get_node(burning_node).name, "flammable") > 1 then

            local node_name = minetest.get_node(burning_node).name
            local after_burned = md_fire.registered_flammables[node_name].after_burned
            minetest.set_node(burning_node, {name = after_burned})
            minetest.get_node_timer(burning_node):start(7.5) -- adjust timer later
        end

        -- 1 in 6 chance to turn into ash/charcoal
        if math.random(1, 8) == 1 then
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

minetest.register_node("md_fire:ash_dust", {
    description = "ash_dust",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    tiles = {"ash.png"},
    groups = {granular = 1, falling_node = 1},
})

minetest.register_node("md_fire:charcoal", {
    description = "charcoal",
    drawtype = "normal",
    tiles = {"charcoal.png"},
    groups = {granular = 2, falling_node = 1, flammable = 2, burn_chance = 10},
})