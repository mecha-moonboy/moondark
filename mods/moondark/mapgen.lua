minetest.register_alias("mapgen_stone", "moondark:stone")
minetest.register_alias("mapgen_water_source", "moondark:water_source")
minetest.register_alias("dirt", "moondark:dirt")
minetest.register_alias("sand", "moondark:sand")
minetest.register_alias("turf", "moondark:turf")
minetest.register_alias("snow", "moondark:snow")
minetest.register_alias("oak", "moondark:oak_log")

--[[
    To Do:
    - Add biomes:
        - desert
        - chasm
        - swamp
        - spruce forest
        - snowy plains
        - snowy forest
    - Add decor:
        - flowers
        - trees:
            - palm tree
            - pine tree
            - swamp tree

]]--



--minetest.set_mapgen_setting(name, value, [override_meta])
-- minetest.set_mapgen_setting_noiseparams("mgvalleys_np_terrain_height", {
-- 	lacunarity = 2,
-- 	persistence = 0.7,
-- 	seed = 5202,
-- 	spread = {x=1024,y=1024,z=1024},
-- 	scale = 50,
-- 	octaves = 8,
-- 	offset = -0.4,
-- }, true)

-- minetest.set_noiseparams("mgvalleys_np_valley_depth", {
-- 	lacunarity = 2,
-- 	persistence = 1,
-- 	seed = -1914,
-- 	spread = {x=512,y=512,z=512},
-- 	scale = 1,
-- 	octaves = 1,
-- 	offset = 5,
-- })

-- Plains
minetest.register_biome({
    name = "plains",
    node_top = "turf",
    node_stone = "mapgen_stone",
    depth_top = 1,
    node_filler = "dirt",
    depth_filler = 10,
    node_river_water = "mapgen_water_source",
    vertical_blend = 16,
    y_max = 100,
	y_min = 10,
    humidity_point = 38
})

-- Oak Forest
minetest.register_biome({
    name = "lowan_forest",
    node_top = "turf",
    node_stone = "mapgen_stone",
    depth_top = 1,
    node_filler = "dirt",
    depth_filler = 10,
    node_river_water = "mapgen_water_source",
    vertical_blend = 16,
    y_max = 100,
	y_min = 10,
    humidity_point = 50
})

-- Stone Slopes
minetest.register_biome({
    name = "stone_slopes",
    --node_top = "snow",
    node_stone = "mapgen_stone",
    depth_top = 1,
    --node_filler = "dirt",
    --depth_filler = 10,
    node_river_water = "mapgen_water_source",
    y_max = 200,
	y_min = 100,
})

-- Snow Peak
minetest.register_biome({
    name = "snow_peak",
    node_top = "snow",
    node_stone = "mapgen_stone",
    depth_top = 1,
    node_filler = "snow",
    depth_filler = 10,
    node_river_water = "mapgen_water_source",
    y_max = 31000,
	y_min = 200,
})
 -- Beach
minetest.register_biome({
    name = "beach",
    node_top = "sand",
    node_stone = "mapgen_stone",
    depth_top = 1,
    node_filler = "sand",
    depth_filler = 10,
    node_river_water = "mapgen_water_source",
    node_riverbed = "moondark:clay",
    depth_riverbed = 1,
    vertical_blend = 32,
    y_max = 32,
	y_min = -100,
})

-- Trees
-- Lowan
minetest.register_decoration({
    name = "moondark:lowan_tree",
    deco_type = "schematic",
    place_on = {"moondark:turf"},
    sidelen = 23,
    place_offset_y = -2,
    noise_params = {
        offset = 0.0,
        scale = 0.1,
        spread = {x = 512, y = 512, z = 512},
        seed = 2,
        octaves = 1,
        persist = 1
    },
    biomes = {"lowan_forest"},
    y_max = 150,
    y_min = 10,
    schematic = minetest.get_modpath("moondark").."/schematics/lowan_tree.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})

-- Malpa
minetest.register_decoration({
    name = "moondark:malpa_tree",
    deco_type = "schematic",
    place_on = {"moondark:sand"},
    sidelen = 256,
    place_offset_y = -2,
    noise_params = {
        offset = 0.0,
        scale = 0.0035,
        spread = {x = 256, y = 256, z = 256},
        seed = 2,
        octaves = 1,
        persist = 1
    },
    biomes = {"beach"},
    y_max = 8,
    y_min = 2,
    schematic = minetest.get_modpath("moondark").."/schematics/malpa_tree.mts",
    flags = "place_center_x, place_center_z",
    rotation = "random",
})

-- Vegetation & misc

minetest.register_decoration({ name = "moondark:grass",
    deco_type = "simple",
    place_on = {"moondark:turf"},
    sidelen = 16,
    fill_ratio = 0.1,
    y_max = 150,
    y_min = 1,
    decoration = "moondark:grass",
})

minetest.register_decoration({ name = "moondark:rock",
    deco_type = "simple",
    place_on = {"moondark:stone"},
    sidelen = 16,
    noise_params = {
        offset = 0.1,
        scale = 0.005,
        spread = {x = 100, y = 100, z = 100},
        seed = 329,
        octaves = 1,
        persist = 0.6
    },
    y_max = 300,
    y_min = -3000,
    decoration = "moondark:rock",
})