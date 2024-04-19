local def_setting = mapgen_rivers.define_setting

mapgen_rivers.noise_params = {
	base = def_setting('np_base', 'noise', {
		offset = 0,
		scale = 300,
		seed = 2469,
		octaves = 8,
		spread = {x=2048, y=2048, z=2048},
		persist = 0.6,
		lacunarity = 2,
		flags = "eased",
	}),

	distort_x = def_setting('np_distort_x', 'noise', {
		offset = 0,
		scale = 1,
		seed = -4574,
		spread = {x=64, y=32, z=64},
		octaves = 3,
		persistence = 0.75,
		lacunarity = 2,
	}),

	distort_z = def_setting('np_distort_z', 'noise', {
		offset = 0,
		scale = 1,
		seed = -7940,
		spread = {x=64, y=32, z=64},
		octaves = 3,
		persistence = 0.75,
		lacunarity = 2,
	}),

	distort_amplitude = def_setting('np_distort_amplitude', 'noise', {
		offset = 0,
		scale = 10,
		seed = 676,
		spread = {x=1024, y=1024, z=1024},
		octaves = 5,
		persistence = 0.5,
		lacunarity = 2,
		flags = "absvalue",
	}),

	heat = minetest.get_mapgen_setting_noiseparams('mg_biome_np_heat'),
	heat_blend = minetest.get_mapgen_setting_noiseparams('mg_biome_np_heat_blend'),
}

-- Convert to number because Minetest API is not able to do it cleanly...
for name, np in pairs(mapgen_rivers.noise_params) do
	for field, value in pairs(np) do
		if field ~= 'flags' and type(value) == 'string' then
			np[field] = tonumber(value) or value
		elseif field == 'spread' then
			for dir, v in pairs(value) do
				value[dir] = tonumber(v) or v
			end
		end
	end
end

local heat = mapgen_rivers.noise_params.heat
local base = mapgen_rivers.noise_params.base
local settings = mapgen_rivers.settings
heat.offset = heat.offset + settings.sea_level * settings.elevation_chill
base.spread.x = base.spread.x / settings.blocksize
base.spread.y = base.spread.y / settings.blocksize
base.spread.z = base.spread.z / settings.blocksize

for name, np in pairs(mapgen_rivers.noise_params) do
	local lac = np.lacunarity or 2
	if lac > 1 then
		local omax = math.floor(math.log(math.min(np.spread.x, np.spread.y, np.spread.z)) / math.log(lac))+1
		if np.octaves > omax then
			minetest.log("warning", "[mapgen_rivers] Noise " .. name .. ": 'octaves' reduced to " .. omax)
			np.octaves = omax
		end
	end
end
