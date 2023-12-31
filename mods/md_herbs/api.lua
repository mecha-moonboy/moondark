md_herbs = {}
md_herbs.registered_herbs = {}

--[[
Herb Definition:

herb_node = "modname:herb_node",
    -- the node to place

weight = 10,
    -- random weight for growth

light = 12,
altitude_max = 180,
altitude_min = 20,
min_humidity = 45,
max_humidity = 60,
min_heat = 30,
max_heat = 60,
    -- all conditions needed for spawning


]]

function md_herbs.register_herb(herb_definition)
    local ind = #md_herbs.registered_herbs + 1
    -- add herb definition to list
    --table.insert(md_herbs.registered_herbs, ind, herb_definition)
    md_herbs.registered_herbs[ind] = herb_definition
    --moondark_core.log("Herb added to registry..." .. md_herbs.registered_herbs[ind].herb_node)

end

function md_herbs.check_conditions(pos, herb)

    if herb.max_altitude and pos.y > herb.max_altitude then
        return false
    end

    if herb.min_altitude and pos.y < herb.min_altitude then
        return false
    end

    if herb.max_light and minetest.get_node_light(pos, 0.5) > herb.max_light then
        return false
    end

    if herb.min_light and minetest.get_node_light(pos, 0.5) < herb.min_light then
        return false
    end

    if herb.max_heat and minetest.get_heat(pos) > herb.max_heat then
        return false
    end

    if herb.min_heat and minetest.get_heat(pos) < herb.min_heat then
        return false
    end

    if herb.max_humidity and minetest.get_humidity(pos) > herb.max_humidity then
        return false
    end

    if herb.min_humidity and minetest.get_humidity(pos) < herb.min_humidity then
        return false
    end

    return true
end

-- called once on the herb placement ABM
function md_herbs.attempt_place_herb(pos, node)
    if minetest.get_node(pos).name ~= "air" then
        return
    end


end

minetest.register_abm({
    nodenames = {"group:soil"},
    interval = 10,
    -- Operation interval in seconds

    chance = 250,
    -- Chance of triggering `action` per-node per-interval is 1.0 / chance

    min_y = 0,
    max_y = 500,

    catch_up = true, -- catch up after been absent from an area

    action = function(pos, node)
        local targ_pos = pos:offset(0, 1, 0)
        if minetest.get_node(targ_pos).name ~= "air" then
            return
        end
        local total_weight = 0
        for _, herb in ipairs(md_herbs.registered_herbs) do
            total_weight = total_weight + herb.weight
        end

        local rand = math.random(total_weight)
        local herb_to_place

        for _, herb in ipairs(md_herbs.registered_herbs) do
            --rand = rand - herb.weight
            if rand < herb.weight and md_herbs.check_conditions(targ_pos, herb) then
                herb_to_place = herb
            end
        end
        -- for i = 1, 5, 1 do
        --     -- choose a random herb
        --     local rand_ind = math.random(0, total_weight)
        --     local accum_weight = 0
        --     local new_herb = nil
        --     --moondark_core.log(dump(md_herbs.registered_herbs))
        --     for _, herb in ipairs(md_herbs.registered_herbs) do
        --         moondark_core.log("Checking out an herb")

        --         accum_weight = accum_weight + herb.weight

        --         if herb and rand_ind <= accum_weight then
        --             new_herb = herb -- Select the herb
        --         end
        --     end

        --     -- check herb conditions
        --     if new_herb and md_herbs.check_conditions(pos, new_herb) then
        --         herb_to_place = new_herb
        --         i = 4
        --     end

        --     -- if invalid, retry
        -- end

        -- place herb node
        if herb_to_place and minetest.get_node(targ_pos).name == "air" then
            minetest.set_node(targ_pos, {name = herb_to_place.herb_node})
            --moondark_core.log("Herb placement successful.")
        end
    end,
})

-- function md_herbs.register_herb_ABMS()
--     minetest.register_abm({
--         nodenames = {"group:soil"},
--         interval = 10.0,
--         -- Operation interval in seconds

--         chance = 1,
--         -- Chance of triggering `action` per-node per-interval is 1.0 / chance

--         min_y = 0,
--         max_y = 500,

--         catch_up = true, -- catch up after been absent from an area

--         action = function(pos, node)
--             md_herbs.attempt_place_herb(pos, node)
--         end,
--     })
-- end