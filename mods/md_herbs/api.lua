md_herbs = {}
md_herbs.registered_herbs = {}

--[[
Herb Definition:

herb_node = "modname:herb_node",
    -- the node to place

weight = 10,
    -- random weight for growth

light = 12,
altitude_max = 180,
altitude_min = 20,
min_humidity = 45,
max_humidity = 60,
min_heat = 30,
max_heat = 60,
    -- all conditions needed for spawning


]]

function md_herbs.register_herb(name, herb_definition)
    -- add herb definition to list
    md_herbs.registered_herbs[name] = herb_definition
end

function md_herbs.register_herb_ABMS()

end