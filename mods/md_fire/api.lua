
md_fire.registered_fire_recipes = {}
md_fire.registered_fire_nodes = {}
md_fire.registered_flammables = {}
md_fire.registered_flammables["moondark:charcoal"] = {after_burned = "md_fire:ember"}

-- register fire recipe
function md_fire.register_fire_recipe(input_name, recipe_def)
    md_fire.registered_fire_recipes[input_name] = recipe_def
end

-- add the flammable group to a node/item/tool
function md_fire.register_flammable_item(item_name, combustion_data)
    md_fire.registered_flammables[item_name] = combustion_data

    local new_groups = {}
    for k, v in pairs(minetest.registered_items[item_name].groups) do
        new_groups[k] = v
    end
    new_groups.flammable = combustion_data.flammable
    new_groups.burn_chance = combustion_data.burn_chance
    minetest.override_item(item_name, {
        groups = new_groups,
    })
    --minetest.log(dump(minetest.registered_items[item_name].groups))
end

-- add the flammable group to a node/item/tool
function md_fire.register_breathable_node(item_name, level)
    local new_groups = {}
    for k, v in pairs(minetest.registered_nodes[item_name].groups) do
        new_groups[k] = v
    end
    new_groups.breathable = level
    minetest.override_item(item_name, {
        groups = new_groups
    })
    --minetest.log(dump(minetest.registered_items[item_name].groups))
end

-- get the output of a given item being cooked
function md_fire.get_recipe_output(item_name)
    return md_fire.registered_fire_recipes[item_name].output
end

-- check if node has fuel nearby
function md_fire.node_near_fuel(pos)
    local fuel_nodes = moondark_core.get_surrounding_nodes_of_group(pos, "flammable")
    return (#fuel_nodes ~= 0)
end

function md_fire.attempt_ignite(pos)
    if md_fire.check_can_ignite(pos) then
        local air_pos = minetest.find_node_near(pos, 1, "air")
        minetest.set_node(air_pos, {name = "md_fire:fire_1"})
        return true
    end
    return false
end

-- check if node can be ignited
function md_fire.check_can_ignite(pos)
    -- position isn't air, return false
    local air_near = minetest.find_node_near(pos, 1, "air")
    --local node_above = minetest.get_node(pos:offset(0, 1, 0))
    if not air_near then
        return false
    end
    -- there isn't a fuel block nearby
    if not md_fire.node_near_fuel(air_near) then return false end

    return true
end

function md_fire.flammable_node_around_pos(pos)
    local pos_list = {
    }

    for i = 1, 3, 1 do
        for j = 1, 3, 1 do
            for k = 1, 3, 1 do
                table.insert(pos_list, #pos_list, pos:offset(i - 2, j - 2, k - 2))
            end
        end
    end

    local flammable_nodes = {}
    for _, pos in ipairs(pos_list) do
        if minetest.get_node_group(minetest.get_node(pos).name, "flammable") ~= 0 then
            table.insert(flammable_nodes, #flammable_nodes, pos)
        end
    end

    return flammable_nodes[math.random(1, #flammable_nodes)]
end

function md_fire.register_fire_node(fire_node_def)

    local temp = table.copy(md_fire.fire_node_template)

    temp.description = fire_node_def.name
    temp.groups.fire = fire_node_def.heat
    temp.tiles[1] = fire_node_def.tiles
    temp.damage_per_second = fire_node_def.damage
    temp.light_source = fire_node_def.light
    temp.on_construct = function(pos)
        minetest.get_node_timer(pos):start(fire_node_def.tick_length + math.random(1, fire_node_def.tick_variance) - 1)
    end
    temp.on_timer = function(pos, elapsed)

        -- removing flame if no fuel present
        if not md_fire.node_near_fuel(pos) then
            minetest.remove_node(pos)-- remove node
            return false
        end

        -- define a random air node and ignite it
        local flammable_nodes = moondark_core.get_nodes_of_group_from_26(pos:offset(0, 0, 0), "flammable")
        local rand_node = flammable_nodes[math.random(1, #flammable_nodes)]
        if rand_node then
            md_fire.attempt_ignite(rand_node)
        end

        -- if burn chance is zero, block won't go away
        -- If the random node can burn, attempt to burn it
        local burning_pos = minetest.find_node_near(pos, 1, "group:flammable")
        if burning_pos ~= nil then
            local node_name = minetest.get_node(burning_pos).name
            local flammable_grp = minetest.get_node_group(node_name, "flammable")
            local brn_chc_grp = minetest.get_node_group(node_name, "burn_chance")
            local fire_grp = minetest.get_node_group(minetest.get_node(pos).name, "fire")
            if flammable_grp > fire_grp then -- there is still latent energy potential
                if fire_node_def.hotter_fire then
                    minetest.swap_node(pos, {name = fire_node_def.hotter_fire})
                end
            elseif brn_chc_grp ~= 0 and math.random(1, brn_chc_grp) <= fire_grp then
                local comb_dat = md_fire.registered_flammables[node_name]
                if comb_dat then
                    --minetest.log("Somthing wrong.\n Dumping burning_pos: " .. dump(burning_pos) .. "\n Dumping comb_dat: " .. dump(comb_dat))
                    minetest.swap_node(burning_pos, {name = comb_dat.after_burned})
                    minetest.check_for_falling(burning_pos)
                    if minetest.registered_nodes[comb_dat.after_burned].start_timer then
                        minetest.registered_nodes[comb_dat.after_burned].start_timer(burning_pos)
                    end
                end
            end
        end



        return true
    end
    local node_name = "md_fire:"..fire_node_def.name
    md_fire.registered_fire_nodes[node_name] = fire_node_def
    minetest.register_node(node_name, temp)
end

-- basic fire node data
md_fire.fire_node_template = {
    drawtype = "firelike",
    visual_scale = 1.0,
    tiles = {"fire.png"},
    use_texture_alpha = "clip",
    color = "#ffffffff",
    post_effect_color = "#00000000",
    paramtype = "light",
    sunlight_propagates = true,
    groups = {fire = 1, --[[not_in_creative_inventory = 1]]},
    walkable = false,
    buildable_to = true,
    pointable = false,
    damage_per_second = 1,
    selection_box = {
        type = "fixed",
		fixed = {-1/2, -1/2,-1/2, 1/2, -1/8, 1/2},
    },
}