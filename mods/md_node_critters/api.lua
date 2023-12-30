local PL = moondark_core.pixel_lengths

-- most large functions should go here

-- get a random air node in a cardinal direction
function md_node_critters.get_random_air(start_pos, tries)
    local attempt = 0
    local ret_pos = nil
    while attempt < tries and not ret_pos do
        attempt = attempt + 1
        local rand_dir = math.random(1, 6)
        local rand_pos
        if rand_dir == 1 then -- up
            rand_pos = start_pos:offset(0, 1, 0)
        elseif rand_dir == 2 then -- down
            rand_pos = start_pos:offset(0, -1, 0)
        elseif rand_dir == 3 then -- forward
            rand_pos = start_pos:offset(0, 0, 1)
        elseif rand_dir == 4 then -- backward
            rand_pos = start_pos:offset(0, 0, -1)
        elseif rand_dir == 5 then -- east
            rand_pos = start_pos:offset(1, 0, 0)
        elseif rand_dir == 6 then -- west
            rand_pos = start_pos:offset(-1, 0, 0) -- I hope i'm not messing up thes directions, was left hand or right hand... can't remember
        end
        if minetest.get_node(rand_pos).name == "air" then
            ret_pos = rand_pos -- ret_pos not nil, so while loop will return, right?...
        end
    end

    return ret_pos
end



-- check a specific direction
-- 1 - up, 2 - down, 3 - north, 4 - south, 5 - east, 6 - west
function md_node_critters.try_dir_air(start_pos, dir_int)
    local check_dir
    if dir_int == 1 then -- up
        check_dir = start_pos:offset(0, 1, 0)
    elseif dir_int == 2 then -- down
        check_dir = start_pos:offset(0, -1, 0)
    elseif dir_int == 3 then -- forward
        check_dir = start_pos:offset(0, 0, 1)
    elseif dir_int == 4 then -- backward
        check_dir = start_pos:offset(0, 0, -1)
    elseif dir_int == 5 then -- east
        check_dir = start_pos:offset(1, 0, 0)
    elseif dir_int == 6 then -- west
        check_dir = start_pos:offset(-1, 0, 0) -- I hope i'm not messing up thes directions, was left hand or right hand... can't remember
    end
    local check_node = minetest.get_node(check_dir)
    if check_node.name == "air" then
        return check_dir
    end
    return nil
end

function md_node_critters.get_air_height(start_pos, max_dist)
    --minetest.log("Getting critter node height...")
    local height = 0
    local last_block_name = "air"
    while last_block_name == "air" and height < max_dist do
        local checking_pos = start_pos:offset(0, -height - 1, 0) -- looking below
        local checking_node = minetest.get_node(checking_pos)
        --minetest.log("Checking node for height check, name: " .. checking_node.name)
        if checking_node.name == "air" then
            height = height + 1
        else
            last_block_name = checking_node.name
        end
    end
    return height
end

-- Modes:
-- - "ground"
-- - "flying"
-- - "clumsy"
function md_node_critters.try_random_air(start_pos, mode, max_height)
    --minetest.log("Attempting to get a random air block...")

    local ret_pos -- return value

    if mode == "flying" then
        local height = md_node_critters.get_air_height(start_pos, 32)
        --minetest.log("Critter height: " .. height)
        if height > max_height then
            local i = 0
            while ret_pos == nil and i < 5 do
                i = i + 1
                local try_pos = md_node_critters.get_random_air(start_pos, 1)
                if try_pos and try_pos.y < 1 then
                    ret_pos = try_pos
                end
            end
        end
        if ret_pos then return ret_pos end

            -- try random direction
        ret_pos = md_node_critters.get_random_air(start_pos, 4)
        if ret_pos then return ret_pos end

        -- fall back on nearest air
        ret_pos = minetest.find_node_near(start_pos, 1, "air")
        if ret_pos then return ret_pos end
    end
    return nil
end

function md_node_critters.create_critter_on_timer(critter_def)
    local old_ret_func -- function to return at the end of this one

    -- if beh_table.repelled_nodes then
    --     local new_ret_func = function(pos, elapsed)
    --         -- do repelling behaviors here
    --         for node_name, distance in pairs(beh_table.repelled_nodes) do
    --             local rep_node = minetest.find_node_near(pos, distance, node_name, [search_center])
    --         end
    --         old_ret_func(pos, elapsed)
    --     end
    --     old_ret_func = new_ret_func
    -- end

    -- if beh_table.attracted_nodes then
    --     local new_ret_func = function(pos, elapsed)
    --         -- do following behaviors here
    --         old_ret_func(pos, elapsed)
    --     end
    --     old_ret_func = new_ret_func
    -- end

    -- otherwise do regular move behavior
    --minetest.log("Creating on_timer function")
    local rand_move_func = function(pos, elapsed)
        if critter_def.night_only then
            local day_time = minetest.get_timeofday()
            local light = minetest.get_node_light(pos)
            --minetest.log("Time of day: " .. day_time)
            --minetest.log("Light level: " .. light)
            if not (light <= critter_def.light) and (day_time < critter_def.later_than and day_time > critter_def.earlier_than) then
                minetest.set_node(pos, {name = "md_node_critters:" .. critter_def.name .. "_off"})
                --minetest.log("Turning off " .. critter_def.name .. ".")
                minetest.get_node_timer(pos):start(math.random(critter_def.min_time, critter_def.max_time))
                return false
            end
        end

        minetest.get_node_timer(pos):start(critter_def.min_time, critter_def.max_time)
        --if old_ret_func then old_ret_func() end
        local rand_air = md_node_critters.try_random_air(pos, "flying", 16)
        if rand_air then
            minetest.set_node(rand_air, minetest.get_node(pos))
            minetest.get_node_timer(rand_air):start(math.random(critter_def.min_time, critter_def.max_time))
            --minetest.place_node(rand_air, minetest.get_node(pos))
            minetest.remove_node(pos)
        end
    end
    old_ret_func = rand_move_func


    -- old_ret_func = new_ret_func
     return old_ret_func
end

function md_node_critters.register_critter(critter_def)

    local critter_on_timer = md_node_critters.create_critter_on_timer(critter_def)

    minetest.register_node("md_node_critters:" .. critter_def.name, {
        description = critter_def.name,
        tiles = {"blank.png"},
        drawtype = "nodebox",
        node_box = {
            type = "fixed",
            fixed = {PL.px_1_8, PL.px_1_8, PL.px_1_8, -PL.px_1_8, -PL.px_1_8, -PL.px_1_8}
        },
        color = critter_def.color,
        inventory_image = critter_def.name .. ".png",
        wield_image =  critter_def.name .. ".png",
        light_source = critter_def.light,
        paramtype = "light",
        drops = "md_node_critters:" .. critter_def.name,
        on_punch = function(pos)
            --minetest.log("critter was punched")
            if math.random(1, critter_def.catch_chance) == 1 then
                moondark_core.simple_destroy_node(pos, "hand")
                return
            end
            minetest.get_node_timer(pos):start(0.01)
        end,
        on_construct = function(pos)
            -- start node timer
            --minetest.log("critter on_construct function")
            minetest.get_node_timer(pos):start(math.random(critter_def.min_time, critter_def.max_time))
        end,
        -- on_place = function(itemstack, placer, pointed_thing)
        --     minetest.log("critter on_place function")
        --     local pos = pointed_thing.above
        --     minetest.get_node_timer(pos):start(1)
        --     return itemstack:take_item(1)
        -- end,
        on_timer = critter_on_timer,
    })

    if critter_def.night_only then
        minetest.register_node("md_node_critters:" .. critter_def.name .. "_off", {
            description = critter_def.name,
            tiles = {"blank.png"},
            drawtype = "airlike",
            groups = {not_in_creative_inventory = 1},
            on_construct = function(pos)
                -- start node timer
                minetest.get_node_timer(pos):start(0)
            end,
            on_timer = function(pos, elapsed)
                --minetest.log("Doing midlight_off functions")
                local time = minetest.get_timeofday()
                local light = minetest.get_node_light(pos)
                if --[[light < critter_def.light - 1 or]] (time > critter_def.later_than or time < critter_def.earlier_than) then
                    minetest.set_node(pos, {name = "md_node_critters:"..critter_def.name})
                    --minetest.log("Turning on critter")
                end

                minetest.get_node_timer(pos):start(math.random(critter_def.min_time, critter_def.max_time))
                return false
            end
        })
    end
end