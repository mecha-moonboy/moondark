md_mobs = {}
local modname = minetest.get_modpath("md_mobs")

minetest.register_globalstep(function(dtime)
    -- despawn step
    -- spawn step
    -- execute hostile brains
    -- execute natural brains
end)

-- minetest.register_on_generated(function(minp, maxp, blockseed)
--     -- do things when a map chunk is generated
-- end)

dofile(modname .. "/api.lua")
dofile(modname .. "/actions.lua")
dofile(modname .. "/behaviors.lua")
dofile(modname .. "/mobs/weaver.lua")