-- Embers block
-- if exposed to air or ash, chance to turn to ash and faster timer
-- if not exposed to air, slower timer, but will turn to charcoal instead.
minetest.register_node("md_fire:ember", {
    description = "embers",
    drawtype = "normal",
    tiles = {"embers.png"},
    groups = {granular = 1, },
    drop = "md_fire:ash",
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(15, 30))
    end,
    start_timer = function(pos)
        minetest.get_node_timer(pos):start(math.random(15, 30))
    end,
    on_timer = function(pos, elapsed)
        for i = 1, 2, 1 do
            -- choose a burnable block to turn into ember
            local targ_pos = minetest.find_node_near(pos, 1, "group:flammable")

            -- there is a node to burn that is not charcoal
            -- replace it with it's after_burned node
            if targ_pos == nil then break end

            if minetest.get_node(targ_pos).name ~= "md_fire:charcoal" and
            minetest.get_node_group(minetest.get_node(targ_pos).name, "flammable") > 1 then
                local node_name = minetest.get_node(targ_pos).name
                if md_fire.attempt_ignite(targ_pos) then break end

                -- if block couldn't be ignited,
                -- random chance to turn it into
                -- it's burnt block instead
                if math.random(1, 3) ~= 1 then break end
                local after_burned = md_fire.registered_flammables[node_name].after_burned
                minetest.swap_node(targ_pos, {name = after_burned})
                minetest.check_for_falling(pos)
                if minetest.registered_nodes[after_burned].start_timer then
                    minetest.registered_nodes[after_burned].start_timer(targ_pos)
                end
            end
        end

        -- 1 in 6 chance to turn into ash/charcoal
        if math.random(1, 2) == 1 then
            -- check if exposed to air or ash
            local oxy_nodes = moondark_core.get_surrounding_nodes_of_group(pos, "breathable")
            local flam_nodes = moondark_core.get_surrounding_nodes_of_group(pos, "flammable")
            -- if it is, turn this node to ash
            if #oxy_nodes ~= 0
            and math.random(1, 6) < #oxy_nodes + #flam_nodes then -- there was enough air for ash
                minetest.swap_node(pos, {name = "md_fire:ash"})
                minetest.check_for_falling(pos)
                return false
            elseif math.random(1, 6) <= 1 then -- there was not enough air for ash
                -- turn to charcoal
                minetest.swap_node(pos, {name = "md_fire:charcoal"})
                minetest.check_for_falling(pos)
                return false
            end
        end
        return true
    end
})

minetest.register_node("md_fire:ash", {
    description = "ash",
    drawtype = "nodebox",
    paramtype2 = "leveled",
    leveled = 8,
    node_box = {
        type = "leveled",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
        },
    },
    tiles = {"ash.png"},
    groups = {granular = 1, falling_node = 1},
    --walkable = false,
})

minetest.register_node("md_fire:charcoal", {
    description = "charcoal",
    drawtype = "normal",
    tiles = {"charcoal.png"},
    groups = {granular = 2, falling_node = 1, flammable = 2, burn_chance = 0},
})