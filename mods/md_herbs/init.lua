md_herbs = {}
local modname = minetest.get_modpath("md_herbs")

-- minetest.register_on_generated(function(minp, maxp, blockseed)
--     -- do things when a map chunk is generated
-- end)

-- minetest.register_globalstep(function(dtime)
--      -- do things every frame
-- end)

dofile(modname .. "/api.lua")
dofile(modname .. "/nodes.lua")
dofile(modname .. "/herbs.lua")