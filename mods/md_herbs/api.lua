md_herbs = {}
md_herbs.registered_herbs = {}


local function checkBiome(targets, biome)
    for _, targ in ipairs(targets) do
        --minetest.log("Checking pair. Target: " .. dump(targ) .. " Biomes " .. dump(biome))
        if biome == targ then
            return true
        end
    end
    return false
end

-- REGISTER --

function md_herbs.register_herb(herb_definition)
    local ind = #md_herbs.registered_herbs + 1
    -- add herb definition to list
    md_herbs.registered_herbs[ind] = herb_definition
end

-- NODE OPERATIONS --

-- run through a list of boolean checks
function md_herbs.check_conditions(pos, herb)
    if herb.max_altitude and pos.y > herb.max_altitude then
        return false
    end

    if herb.min_altitude and pos.y < herb.min_altitude then
        return false
    end

    if herb.biomes then
        local biome_data = minetest.get_biome_data(pos)
        if not checkBiome(herb.biomes, minetest.get_biome_name(biome_data.biome)) then
            --minetest.log("Biome check failed")
            return false
        end
    end

    if herb.node_under and minetest.get_node(pos:offset(0, -1, 0)).name ~= herb.node_under then
        return false
    end

    if herb.max_light and minetest.get_node_light(pos, 0.5) > herb.max_light then
        return false
    end

    if herb.min_light and minetest.get_node_light(pos, 0.5) < herb.min_light then
        --minetest.log("min lighting check failed")
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

    if minetest.find_node_near(pos, herb.min_radius, herb.herb_node, true) then
        minetest.log("Herbs too close together, skipping placement")
        return false
    end

    return true
end

-- called once on the herb placement ABM, checks and places herb
function md_herbs.attempt_place_herb(pos)
    -- no air, cancel
    if minetest.get_node(pos).name ~= "air" then
        return
    end

    local total_weight = 0
    for _, herb in ipairs(md_herbs.registered_herbs) do
        total_weight = total_weight + herb.weight
    end

    local rand = math.random(total_weight)
    local herb_to_place

    for _, herb in ipairs(md_herbs.registered_herbs) do
        rand = rand - herb.weight
        if rand < herb.weight and md_herbs.check_conditions(pos, herb) then
            herb_to_place = herb
        end
    end

    -- place herb node
    if herb_to_place then
        minetest.set_node(pos, {name = herb_to_place.herb_node})
        --moondark_core.log("Herb placement successful.")
    end
end

minetest.register_abm({
    nodenames = {"group:soil"},
    interval = 120,
    -- Operation interval in seconds

    chance = 250,
    -- Chance of triggering `action` per-node per-interval is 1.0 / chance

    min_y = 0,
    max_y = 200,

    catch_up = true, -- catch up after been absent from an area

    action = function(pos, node)
        local targ_pos = pos:offset(0, 1, 0)
        md_herbs.attempt_place_herb(targ_pos)
    end,
})