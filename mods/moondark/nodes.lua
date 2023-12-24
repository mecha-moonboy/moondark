--[[
Breaking/Using Groups:
- hand
- stone [pickaxe]
- soil [shovel]
- wooden [axe]
- fiberous [blade]
- heated [tongs]

Node Type Groups:
- liquid
- falling_node


Ground Nodes:

moondark:stone
moondark:water
moondark:turf
moondark:dirt
moondark:snow
moondark:clay

Tree Nodes:

moondark:lowan_log
moondark:lowan_leaves
moondark:lowan_wood

Plant and Decor Nodes:
moondark:grass
moondark:rock
]]

-- Stone
minetest.register_node("moondark:stone",{
    description = "stone",
    tiles = {
        "blank.png^ground.png^spots.png"
    },
    color = "#131010ff",
    groups = {stone = 4},
})

-- Grainy

minetest.register_node("moondark:turf",{
    description = "turf",
    tiles = {
        {name = "blank.png^ground.png"},

    },
    color = "#002000ff",
    groups = {hand = 3, soil = 1, granular = 2},
    is_ground_content = true,
    on_punch = function(pos, clicker)
        --minetest.remove_node(pos)
    end
})

minetest.register_node("moondark:dirt",{
    description = "dirt",
    tiles = {
        "blank.png^ground.png"
    },
    color = "#261002ff",
    groups = {hand = 2, granular = 2, soil = 1},
    is_ground_content = true,
    on_punch = function(pos, clicker)
        --minetest.remove_node(pos)
    end
})

minetest.register_node("moondark:sand",{
    description = "sand",
    tiles = {
        "blank.png^ground.png"
    },
    color = "#664411ff",
    groups = {hand = 2, granular = 2, falling_node = 1},
    is_ground_content = true,
})

minetest.register_node("moondark:snow",{
    description = "snow",
    tiles = {
        "blank.png^ground.png"
    },
    color = "#9999ddff",
    groups = {hand = 2, granular = 2},
})

minetest.register_node("moondark:clay",{
    description = "clay",
    tiles = {
        "blank.png^ground.png"
    },
    color = "#777777ff",
    groups = {hand = 2, granular = 2},
    drops = {"moondark:clay_blob"},
})

-- Water
minetest.register_node("moondark:water_source",{
    description = "water",

    drawtype = "liquid",
    tiles = {
        "transparent_ground.png"
    },
    use_texture_alpha = "blend",
    color = "#00003355",
    paramtype = "light",

    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,
    groups = {water = 3, liquid = 3},

    drowning = 2,
    liquidtype = "source",
    liquid_alternative_flowing = "moondark:water_flowing",
    liquid_alternative_source = "moondark:water_source",
    liquid_viscosity = 1,
    liquid_renewable = false,
    liquid_range = 2,
    post_effect_color = "#00003399",
})
minetest.register_node("moondark:water_flowing",{
    drawtype = "flowingliquid",
    tiles = {"transparent_ground.png"},
    special_tiles = {
		{
			name = "transparent_ground.png",
			backface_culling = false,
		},
		{
			name = "transparent_ground.png",
			backface_culling = true,
		},
	},
    use_texture_alpha = "blend",
    color = "#00003355",
    paramtype = "light",
	paramtype2 = "flowingliquid",

    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    is_ground_content = false,

    drowning = 2,
    groups = {water = 3, liquid = 3, not_in_creative_inventory = 1},
    liquidtype = "flowing",
    liquid_alternative_flowing = "moondark:water_flowing",
    liquid_alternative_source = "moondark:water_source",
    liquid_viscosity = 1,
    liquid_renewable = false,
    liquid_move_physics = 0,
    liquid_range = 2,
    post_effect_color = "#00003399",
})

-- Trees
minetest.register_node("moondark:lowan_log", {
    description = "lowan log",
    tiles = {
        "stem_top.png",
        "stem_top.png",
        "stem_side.png^[colorize:#441905cc",
    },
    drawtype = "normal",
    paramtype2 = "facedir",
    on_place = minetest.rotate_node,
    after_destruct = function(pos, oldnode)
        moondark_core.start_decay(pos)
        -- check surrounding log nodes

    end,
    is_ground_content = false,
    color = "#552205ff",
    groups = {wooden = 2, log = 1},
    on_punch = function(pos, node, clicker, _)
        return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:lowan_wood 4", 8, "axe")
    end
})

minetest.register_node("moondark:lowan_wood", {
    description = "lowan planks",
    tiles = {
        "planks.png",
    },
    drawtype = "normal",
    --paramtype2 = "facedir",
    --on_place = minetest.rotate_node,
    color = "#552205ff",
    groups = {planks = 2},
    on_punch = function(pos, node, clicker, _)
        return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:stick 4", 8, "axe")
    end
})

minetest.register_node("moondark:lowan_leaves", {
    description = "lowan leaves",
    tiles = {
        "leaves_1.png"
    },
    drawtype = "allfaces_optional",
    color = "#002207ff",
    groups = {hand = 2, fiberous = 1, leaves = 1,},
    drop = {
        max_item = 1,
        items = {
            {items = {"moondark:lowan_seedling"}, rarity = 8},
            {items = {"moondark:stick"}, rarity = 4},
        }
    },
    paramtype = "light",
	walkable = false,
	climbable = true,
    buildable_to = false,
    -- after_destruct = function(pos, oldnode)
    --     moondark_core.start_decay(pos)
    -- end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if not digger then
            return
        end
        if minetest.get_item_group(digger:get_wielded_item(), "sword") then
            for x = -2, 2, 1 do
                for y = -2, 2, 1 do
                    for z = -2, 2, 1 do
                        local pos_offset = pos:offset(x, y, z)
                        if minetest.get_node(pos_offset).name == oldnode.name then
                            moondark_core.simple_destroy_node(pos_offset, "sword")
                        end
                    end
                end
            end
        end
    end,
    on_timer = function(pos, elapsed)
        moondark_core.start_decay(pos)
    end
	--sunlight_propagates = true,
})

minetest.register_node("moondark:lowan_seedling", {
    description = "acorn",
    drawtype = "plantlike",
    color = "#104400ff",
    waving = 1,
    visual_scale = 1.0,
    tiles = {"seedling.png"},
    inventory_image = "acorn.png",
    wield_image = "acorn.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {hand = 2, flora = 1, attached_node = 1, grass = 1},
    selection_box = {
        type = "fixed",
        fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
    },
    drop = "moondark:oak_seedling",
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(3, 15))
    end,
    on_timer = moondark_core.grow_sapling,
})


minetest.register_node("moondark:malpa_log", {
    description = "malpa log",
    tiles = {
        "stem_top.png",
        "stem_top.png",
        "blank.png^wave.png",
    },
    drawtype = "normal",
    paramtype2 = "facedir",
    on_place = minetest.rotate_node,
    after_destruct = function(pos, oldnode)
        moondark_core.start_decay(pos)
        -- check surrounding log nodes

    end,
    is_ground_content = false,
    color = "#776622ff",
    groups = {wooden = 2, log = 1},
    -- on_punch = function(pos, node, clicker, _)
    --     return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:lowan_wood 4", 8, "axe")
    -- end
})

minetest.register_node("moondark:malpa_wood", {
    description = "malpa planks",
    tiles = {
        "planks.png",
    },
    drawtype = "normal",
    --paramtype2 = "facedir",
    --on_place = minetest.rotate_node,
    color = "#776622ff",
    groups = {planks = 2},
    on_punch = function(pos, node, clicker, _)
        return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:stick 4", 8, "axe")
    end
})

minetest.register_node("moondark:malpa_leaves", {
    description = "malpa leaves",
    tiles = {
        "malpa_leaves.png",
    },
    drawtype = "mesh",
    mesh = "all_faces.obj",
    color = "#062705ff",
    use_texture_alpha = "clip",
    groups = {hand = 2, fiberous = 1, leaves = 1},
    selection_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
        },
    },
    drop = "",
    paramtype = "light",
	walkable = false,
	climbable = true,
    buildable_to = false,
    after_destruct = function(pos, oldnode)
        moondark_core.start_decay(pos)
    end,
    -- after_dig_node = function(pos, oldnode, oldmetadata, digger)
    --     if not digger then
    --         return
    --     end
    --     if minetest.get_item_group(digger:get_wielded_item(), "sword") then
    --         for x = -2, 2, 1 do
    --             for y = -2, 2, 1 do
    --                 for z = -2, 2, 1 do
    --                     local pos_offset = pos:offset(x, y, z)
    --                     if minetest.get_node(pos_offset).name == oldnode.name then
    --                         moondark_core.simple_destroy_node(pos_offset, "sword")
    --                     end
    --                 end
    --             end
    --         end
    --     end
    -- end,
    on_timer = function(pos, elapsed)
        moondark_core.start_decay(pos)
    end,
	sunlight_propagates = true,
})
local px_3 = 0.5*3/4
local px_2 = 0.25
local px_1 = 0.5/4
minetest.register_node("moondark:noconut", {
    description = "noconut",
    drawtype = "nodebox",
    node_box = {
        type = "connected",
        fixed = {
            {-px_3, -px_3, -px_3, px_3, px_3, px_3},
        },
        connect_top = {
            {-px_3, -0.25, -px_3, px_3, 0.5 , px_3}
        },
        connect_bottom = {
            {-px_3, -0.5, -px_3, px_3, 0.25 , px_3}
        }
    },
    connect_sides = { "top", "bottom", },
    color = "#331101ff",
    visual_scale = 1.0,
    tiles = {"nut_1.png"},
    inventory_image = "nut_1.png",
    wield_image = "nut_1.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = false,
    groups = {hand = 2, flammable = 1,falling_node = 1, attached_node=1,},
    after_place_node = function(pos, placer, itemstack)
		minetest.set_node(pos, {name = "moondark:noconut", param2 = 3})
	end,
    drop = "moondark:noconut",
})


minetest.register_node("moondark:sprute_log", {
    description = "sprute log",
    tiles = {
        "stem_top.png",
        "stem_top.png",
        "stem_side.png^[colorize:#332415cc",
    },
    drawtype = "normal",
    paramtype2 = "facedir",
    on_place = minetest.rotate_node,
    after_destruct = function(pos, oldnode)
        moondark_core.start_decay(pos)
        -- check surrounding log nodes

    end,
    is_ground_content = false,
    color = "#554415ff",
    groups = {wooden = 2, log = 1},
    on_punch = function(pos, node, clicker, _)
        return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:sprute_wood 4", 8, "axe")
    end
})

minetest.register_node("moondark:sprute_wood", {
    description = "sprute planks",
    tiles = {
        "planks.png",
    },
    drawtype = "normal",
    --paramtype2 = "facedir",
    --on_place = minetest.rotate_node,
    color = "#554415ff",
    groups = {planks = 2},
    on_punch = function(pos, node, clicker, _)
        return moondark_core.pummel_attempt_drop(pos, clicker, "moondark:stick 4", 8, "axe")
    end
})

minetest.register_node("moondark:sprute_needles", {
    description = "sprute needles",
    tiles = {
        "needles_side.png"
    },
    drawtype = "allfaces_optional",
    color = "#002211ff",
    groups = {hand = 2, fiberous = 1, leaves = 1,},
    drop = {
        max_item = 1,
        items = {
            --{items = {"moondark:lowan_seedling"}, rarity = 8},
            {items = {"moondark:stick"}, rarity = 4},
        }
    },
    paramtype = "light",
	walkable = false,
	climbable = true,
    buildable_to = false,
    -- after_destruct = function(pos, oldnode)
    --     moondark_core.start_decay(pos)
    -- end,
    after_dig_node = function(pos, oldnode, oldmetadata, digger)
        if not digger then
            return
        end
        if minetest.get_item_group(digger:get_wielded_item(), "sword") then
            for x = -2, 2, 1 do
                for y = -2, 2, 1 do
                    for z = -2, 2, 1 do
                        local pos_offset = pos:offset(x, y, z)
                        if minetest.get_node(pos_offset).name == oldnode.name then
                            moondark_core.simple_destroy_node(pos_offset, "sword")
                        end
                    end
                end
            end
        end
    end,
    on_timer = function(pos, elapsed)
        moondark_core.start_decay(pos)
    end
	--sunlight_propagates = true,
})

-- minetest.register_node("moondark:sprute_seedling", {
--     description = "acorn",
--     drawtype = "plantlike",
--     color = "#104400ff",
--     waving = 1,
--     visual_scale = 1.0,
--     tiles = {"seedling.png"},
--     inventory_image = "acorn.png",
--     wield_image = "acorn.png",
--     paramtype = "light",
--     sunlight_propagates = true,
--     walkable = false,
--     buildable_to = true,
--     groups = {hand = 2, flora = 1, attached_node = 1, grass = 1},
--     selection_box = {
--         type = "fixed",
--         fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
--     },
--     drop = "moondark:oak_seedling",
--     on_construct = function(pos)
--         minetest.get_node_timer(pos):start(math.random(3, 15))
--     end,
--     on_timer = moondark_core.grow_sapling,
-- })

-- Plants
minetest.register_node("moondark:grass", {
	description = "grass",
	drawtype = "plantlike",
    color = "#0f2300ff",
	waving = 1,
	visual_scale = 1.0,
	tiles = {"grass.png"},
	inventory_image = "grass.png",
	wield_image = "grass.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = true,
	groups = {hand = 2, fiberous = 1, flora = 1, attached_node = 1, grass = 1},
	selection_box = {
		type = "fixed",
		fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, 0.5, 6 / 16},
	},
    drop = "moondark:straw",
})

-- Decorations
minetest.register_node("moondark:rock", {
    description = "rock",
    tiles = {
        "blank.png^ground.png^spots.png",
    },
    color = "#1a1a1aff",
    --inventory_image = "rock_inv.png",
    --wield_image = "rock_inv.png",
    paramtype = "light",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.25, -0.5, -0.25, 0.25, -0.25, 0.25}, -- rock
        }
    },
    drop = "moondark:rock",
    groups = {stone = 1, hand = 3, projectile = 1},
})

minetest.register_node("moondark:driftwood", {
    description = "driftwood",
    tiles = {
        "blank.png^ground.png",
    },
    paramtype2 = "4dir",
    on_place = minetest.rotate_node,
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {
            {-0.75, -0.5, -0.75, 0.75, -0.125, -0.25},
            {-0.75, -0.5, -0.25, -0.25, -0.125, 0.75},
            {-0.75, -0.125, 0.25, -0.25, 0.75, 0.75},
        }
    },
    color = "#887755ff",
    groups = {not_in_creative_inventory = 1, hand = 2},
    drop = "moondark:stick",
})