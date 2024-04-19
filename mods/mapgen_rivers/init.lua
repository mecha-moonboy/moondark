mapgen_rivers = {}

local modpath = minetest.get_modpath(minetest.get_current_modname()) .. '/'
mapgen_rivers.modpath = modpath
mapgen_rivers.world_data_path = minetest.get_worldpath() .. '/river_data/'

if minetest.get_mapgen_setting("mg_name") ~= "singlenode" then
	minetest.set_mapgen_setting("mg_name", "singlenode", true)
	minetest.log("warning", "[mapgen_rivers] Mapgen set to singlenode")
end

dofile(modpath .. 'settings.lua')

local sea_level = mapgen_rivers.settings.sea_level
local elevation_chill = mapgen_rivers.settings.elevation_chill
local use_distort = mapgen_rivers.settings.distort
local use_biomes = mapgen_rivers.settings.biomes
local use_biomegen_mod = use_biomes and minetest.global_exists('biomegen')
use_biomes = use_biomes and minetest.global_exists('default') and not use_biomegen_mod

if use_biomegen_mod then
	biomegen.set_elevation_chill(elevation_chill)
end
dofile(modpath .. 'noises.lua')

local heightmaps = dofile(modpath .. 'heightmap.lua')

-- Linear interpolation
local function interp(v00, v01, v11, v10, xf, zf)
	local v0 = v01*xf + v00*(1-xf)
	local v1 = v11*xf + v10*(1-xf)
	return v1*zf + v0*(1-zf)
end

-- Localize for performance
local floor, min = math.floor, math.min

local data = {}

local noise_x_obj, noise_z_obj, noise_distort_obj, noise_heat_obj, noise_heat_blend_obj
local noise_x_map = {}
local noise_z_map = {}
local noise_distort_map = {}
local noise_heat_map = {}
local noise_heat_blend_map = {}
local mapsize
local init = false

local sumtime = 0
local sumtime2 = 0
local ngen = 0

local function generate(minp, maxp, seed)
	minetest.log("info", ("[mapgen_rivers] Generating from %s to %s"):format(minetest.pos_to_string(minp), minetest.pos_to_string(maxp)))

	local chulens = {
		x = maxp.x-minp.x+1,
		y = maxp.y-minp.y+1,
		z = maxp.z-minp.z+1,
	}

	if not init then
		mapsize = {
			x = chulens.x,
			y = chulens.y+1,
			z = chulens.z,
		}
		if use_distort then
			noise_x_obj = minetest.get_perlin_map(mapgen_rivers.noise_params.distort_x, mapsize)
			noise_z_obj = minetest.get_perlin_map(mapgen_rivers.noise_params.distort_z, mapsize)
			noise_distort_obj = minetest.get_perlin_map(mapgen_rivers.noise_params.distort_amplitude, chulens)
		end
		if use_biomes then
			noise_heat_obj = minetest.get_perlin_map(mapgen_rivers.noise_params.heat, chulens)
			noise_heat_blend_obj = minetest.get_perlin_map(mapgen_rivers.noise_params.heat_blend, chulens)
		end
		init = true
	end

	local t0 = os.clock()
	local minp2d = {x=minp.x, y=minp.z}
	if use_distort then
		noise_x_obj:get_3d_map_flat(minp, noise_x_map)
		noise_z_obj:get_3d_map_flat(minp, noise_z_map)
		noise_distort_obj:get_2d_map_flat(minp2d, noise_distort_map)
	end
	if use_biomes then
		noise_heat_obj:get_2d_map_flat(minp2d, noise_heat_map)
		noise_heat_blend_obj:get_2d_map_flat(minp2d, noise_heat_blend_map)
	end

	local terrain_map, lake_map, incr, i_origin

	if use_distort then
		local xmin, xmax, zmin, zmax = minp.x, maxp.x, minp.z, maxp.z
		local i = 0
		local i2d = 0
		for z=minp.z, maxp.z do
			for y=minp.y, maxp.y+1 do
				for x=minp.x, maxp.x do
					i = i+1
					i2d = i2d+1
					local distort = noise_distort_map[i2d]
					local xv = noise_x_map[i]*distort + x
					if xv < xmin then xmin = xv end
					if xv > xmax then xmax = xv end
					noise_x_map[i] = xv
					local zv = noise_z_map[i]*distort + z
					if zv < zmin then zmin = zv end
					if zv > zmax then zmax = zv end
					noise_z_map[i] = zv
				end
				i2d = i2d-chulens.x
			end
		end

		local pminp = {x=floor(xmin), z=floor(zmin)}
		local pmaxp = {x=floor(xmax)+1, z=floor(zmax)+1}
		incr = pmaxp.x-pminp.x+1
		i_origin = 1 - pminp.z*incr - pminp.x
		terrain_map, lake_map = heightmaps(pminp, pmaxp)
	else
		terrain_map, lake_map = heightmaps(minp, maxp)
	end

	-- Check that there is at least one position that reaches min y
	if minp.y > sea_level then
		local y0 = minp.y
		local is_empty = true
		for i=1, #terrain_map do
			if terrain_map[i] >= y0 or lake_map[i] >= y0 then
				is_empty = false
				break
			end
		end

		-- If not, skip chunk
		if is_empty then
			local t = os.clock() - t0
			ngen = ngen + 1
			sumtime = sumtime + t
			sumtime2 = sumtime2 + t*t

			minetest.log("verbose", "[mapgen_rivers] Skipping empty chunk (fully above ground level)")
			minetest.log("verbose", ("[mapgen_rivers] Done in %5.3f s"):format(t))
			return
		end
	end

	local c_stone = minetest.get_content_id("mapgen_stone")
	local c_water = minetest.get_content_id("mapgen_water_source")
	--local c_rwater = minetest.get_content_id("mapgen_river_water_source")
	local c_rwater = minetest.get_content_id("mapgen_water_source")

	local c_dirt, c_lawn, c_dirtsnow, c_snow, c_sand, c_ice
	if use_biomes then
		c_dirt = minetest.get_content_id("default:dirt")
		c_lawn = minetest.get_content_id("default:dirt_with_grass")
		c_dirtsnow = minetest.get_content_id("default:dirt_with_snow")
		c_snow = minetest.get_content_id("default:snowblock")
		c_sand = minetest.get_content_id("default:sand")
		c_ice = minetest.get_content_id("default:ice")
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(data)

	local a = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local ystride = a.ystride -- Tip : the ystride of a VoxelArea is the number to add to the array index to get the index of the position above. It's faster because it avoids to completely recalculate the index.

	local nid = mapsize.x*(mapsize.y-1) + 1
	local incrY = -mapsize.x
	local incrX = 1 - mapsize.y*incrY
	local incrZ = mapsize.x*mapsize.y - mapsize.x*incrX - mapsize.x*mapsize.y*incrY

	local i2d = 1

	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local ivm = a:index(x, maxp.y+1, z)
			local ground_above = false
			local temperature
			if use_biomes then
				temperature = noise_heat_map[i2d]+noise_heat_blend_map[i2d]
			end
			local terrain, lake
			if not use_distort then
				terrain = terrain_map[i2d]
				lake = lake_map[i2d]
			end

			for y = maxp.y+1, minp.y, -1 do
				if use_distort then
					local xn = noise_x_map[nid]
					local zn = noise_z_map[nid]
					local x0 = floor(xn)
					local z0 = floor(zn)

					local i0 = i_origin + z0*incr + x0
					local i1 = i0+1
					local i2 = i1+incr
					local i3 = i2-1

					terrain = interp(terrain_map[i0], terrain_map[i1], terrain_map[i2], terrain_map[i3], xn-x0, zn-z0)
					lake = min(lake_map[i0], lake_map[i1], lake_map[i2], lake_map[i3])
				end

				if y <= maxp.y then

					local is_lake = lake > terrain
					if y <= terrain then
						if not use_biomes or y <= terrain-1 or ground_above then
							data[ivm] = c_stone
						elseif is_lake or y < sea_level then
							data[ivm] = c_sand
						else
							local temperature_y = temperature - y*elevation_chill
							if temperature_y >= 15 then
								data[ivm] = c_lawn
							elseif temperature_y >= 0 then
								data[ivm] = c_dirtsnow
							else
								data[ivm] = c_snow
							end
						end
					elseif y <= lake and lake > sea_level then
						if not use_biomes or temperature - y*elevation_chill >= 0 then
							data[ivm] = c_rwater
						else
							data[ivm] = c_ice
						end
					elseif y <= sea_level then
						data[ivm] = c_water
					end
				end

				ground_above = y <= terrain

				ivm = ivm - ystride
				if use_distort then
					nid = nid + incrY
				end
			end

			if use_distort then
				nid = nid + incrX
			end
			i2d = i2d + 1
		end

		if use_distort then
			nid = nid + incrZ
		end
	end

	if use_biomegen_mod then
		biomegen.generate_all(data, a, vm, minp, maxp, seed)
	else
		vm:set_data(data)
		minetest.generate_ores(vm, minp, maxp)
	end

	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	local t = os.clock()-t0
	ngen = ngen + 1
	sumtime = sumtime + t
	sumtime2 = sumtime2 + t*t
	minetest.log("verbose", ("[mapgen_rivers] Done in %5.3f s"):format(t))
end

minetest.register_on_generated(generate)
minetest.register_on_shutdown(function()
	local avg = sumtime / ngen
	local std = math.sqrt(sumtime2/ngen - avg*avg)
	minetest.log("action", ("[mapgen_rivers] Mapgen statistics:\n- Mapgen calls: %4d\n- Mean time: %5.3f s\n- Standard deviation: %5.3f s"):format(ngen, avg, std))
end)
