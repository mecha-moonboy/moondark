
md_fire.registered_fire_recipes = {}
md_fire.registered_fire_nodes = {}

-- register fire recipe
function md_fire.register_fire_recipe(item_name, output_name)
    md_fire.registered_fire_recipes[item_name] = output_name
end

-- add the flammable group to a node/item/tool
function md_fire.register_flammable_item(itemname, level)
    local new_groups = table.copy(minetest.registered_items[itemname].groups)
    new_groups.flammable = level
    --minetest.log("Groups: " .. minetest.serialize(new_groups))
    minetest.override_item(itemname, {
        groups = new_groups
    })
end

-- add the breathable group to a node
function md_fire.register_breathable_item(nodename, level)
    local new_groups = table.copy(minetest.registered_nodes[nodename].groups)
    new_groups.breathable = level
    minetest.override_item(nodename, {
        groups = new_groups
    })
end

-- get the output of a given item being cooked
function md_fire.get_recipe_output(item_name)
    return md_fire.registered_fire_recipes[item_name]
end

-- check if node has fuel nearby
function md_fire.node_near_fuel(pos)
    local fuel_nodes = moondark_core.get_surrounding_nodes_of_group(pos, "flammable")
    --minetest.log("Fuel nodes: " .. minetest.serialize(fuel_nodes))
    return (#fuel_nodes ~= 0)
end

function md_fire.attempt_ignite(pos)
    if md_fire.check_can_ignite(pos) then
        minetest.set_node(pos, {name = "md_fire:fire_1"})
        return true
    end
    return false
end

-- check if node can be ignited
function md_fire.check_can_ignite(pos)
    -- position isn't air, return false
    local node = minetest.get_node(pos)
    if node.name ~= "air" then
        return false
    end
    -- there isn't a fuel block nearby
    if not md_fire.node_near_fuel(pos) then return false end

    return true
end

function md_fire.random_node_around_pos(pos)
    local pos_list = {
        pos:offset( 0 , 1 , 0 ), -- above
        pos:offset( 0 ,-1 , 0 ), -- below
        pos:offset( 0 , 0 , 1 ), -- north
        pos:offset( 0 , 0 ,-1 ), -- south
        pos:offset( 1 , 0 , 0 ), -- east
        pos:offset(-1 , 0 , 0 ), -- west
        pos:offset( 0 , 1 , 1 ), -- north above
        pos:offset( 0 , 1 ,-1 ), -- south above
        pos:offset( 1 , 1 , 0 ), -- east above
        pos:offset(-1 , 1 , 0 ), -- west above
        pos:offset( 0 , -1 , 1 ), -- north below
        pos:offset( 0 , -1 ,-1 ), -- south below
        pos:offset( 1 , -1 , 0 ), -- east below
        pos:offset(-1 , -1 , 0 ), -- west below
    }

    return pos_list[math.random(1, #pos_list)]
end

function md_fire.register_fire_node(fire_node_def)

    local temp = table.copy(md_fire.fire_node_template)

    temp.description = fire_node_def.name
    temp.groups.fire = fire_node_def.heat
    temp.tiles[1] = fire_node_def.tiles
    temp.damage_per_second = fire_node_def.damage
    temp.light_source = fire_node_def.light
    temp.on_construct = function(pos)
        minetest.get_node_timer(pos):start(fire_node_def.tick_length)
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
    param2type = "light",
    sunlight_propagates = true,
    groups = {fire = 1, --[[not_in_creative_inventory = 1]]},
    walkable = false,
    buildable_to = false,
    damage_per_second = 1,
    selection_box = {
        type = "fixed",
		fixed = {-1/2, -1/2,-1/2, 1/2, -1/8, 1/2},
    },
    on_timer = function(pos, elapsed)

        -- if no fuel around node
        if not md_fire.node_near_fuel(pos) then
            minetest.remove_node(pos)-- remove node
            return false
        end

        -- define a random air node to ignite
        -- attempt to ignite it
        local rand_node = md_fire.random_node_around_pos(pos)

        if md_fire.attempt_ignite(rand_node) then
            return false
        end

        -- if the rand node's flammable level is higher than
        -- the flame level, upgrade the flame level
        local fire_grp = minetest.get_node_group(minetest.get_node(pos), "fire")
        local flammable_grp = minetest.get_node_group(minetest.get_node(rand_node), "flammable")


        if flammable_grp and flammable_grp >= fire_grp then -- there is still latent energy potential

        else -- fire is at max heat
            -- turn node to ember
            minetest.set_node(rand_node, {name = "md_fire:ember"})
            minetest.get_node_timer(rand_node):start(30)
        end


        -- otherwise, turn the node to ember

        --minetest.log("Executing fire timer. Fuel detected, maintaining existence.")
        return true
    end,
}