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

function md_herbs.register_herb(name, herb_definition)
    -- add herb definition to list
    md_herbs.registered_herbs[name] = herb_definition
end

function md_herbs.attempt_place_herb(pos, node)
    local total_weight = 0
    for _, herb in ipairs(#md_herbs.registered_herbs) do

    end
end

function md_herbs.register_herb_ABMS()
    minetest.register_abm({
        nodenames = {"group:soil"},
        interval = 10.0,
        -- Operation interval in seconds

        chance = 1,
        -- Chance of triggering `action` per-node per-interval is 1.0 / chance

        min_y = 0,
        max_y = 500,

        catch_up = true, -- catch up after been absent from an area

        action = function(pos, node)
            md_herbs.attempt_place_herb(pos, node)
        end,
    })
end