local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

md_effects = {}

md_effects.LEVEL_FACTOR = 1.5
md_effects.DURATION = 1

dofile(modpath .. "/api.lua")