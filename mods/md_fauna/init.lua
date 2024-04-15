md_fauna = {}
local modname = minetest.get_modpath("md_fauna")



if minetest.get_modpath("md_herbs") then

end
if minetest.get_modpath("md_fire") then

end
-- minetest.register_on_generated(function(minp, maxp, blockseed)
--     -- do things when a map chunk is generated
-- end)

-- minetest.register_globalstep(function(dtime)
--      -- do things every frame
-- end)

dofile(modname .. "/mob_ai.lua")
dofile(modname .. "/mobs/whale.lua")