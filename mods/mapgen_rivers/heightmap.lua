local modpath = mapgen_rivers.modpath

local make_polygons = dofile(modpath .. 'polygons.lua')
local transform_quadri = dofile(modpath .. 'geometry.lua')

local sea_level = mapgen_rivers.settings.sea_level
local riverbed_slope = mapgen_rivers.settings.riverbed_slope * mapgen_rivers.settings.blocksize

local MAP_BOTTOM = -31000

-- Localize for performance
local floor, min, max = math.floor, math.min, math.max
local unpk = unpack

-- Linear interpolation
local function interp(v00, v01, v11, v10, xf, zf)
	local v0 = v01*xf + v00*(1-xf)
	local v1 = v11*xf + v10*(1-xf)
	return v1*zf + v0*(1-zf)
end

local function heightmaps(minp, maxp)

	local polygons = make_polygons(minp, maxp)
	local incr = maxp.z-minp.z+1

	local terrain_height_map = {}
	local lake_height_map = {}

	local i = 1
	for z=minp.z, maxp.z do
		for x=minp.x, maxp.x do
			local poly = polygons[i]

			if poly then
				local xf, zf = transform_quadri(poly.x, poly.z, x, z)
				local i00, i01, i11, i10 = unpk(poly.i)

				-- Load river width on 4 edges and corners
				local r_west, r_north, r_east, r_south = unpk(poly.rivers)
				local c_NW, c_NE, c_SE, c_SW = unpk(poly.river_corners)

				-- Calculate the depth factor for each edge and corner.
				-- Depth factor:
				-- < 0: outside river
				-- = 0: on riverbank
				-- > 0: inside river
				local depth_factors = {
					r_west - xf,
					r_north - zf,
					xf - r_east,
					zf - r_south,
					c_NW-xf-zf,
					xf-zf-c_NE,
					xf+zf-c_SE,
					zf-xf-c_SW,
				}

				-- Find the maximal depth factor and determine to which river it belongs
				local depth_factor_max = 0
				local imax = 0
				for i=1, 8 do
					if depth_factors[i] >= depth_factor_max then
						depth_factor_max = depth_factors[i]
						imax = i
					end
				end

				-- Transform the coordinates to have xf and zf = 0 or 1 in rivers (to avoid rivers having lateral slope and to accomodate the surrounding smoothly)
				if imax == 0 then
					local x0 = max(r_west, c_NW-zf, zf-c_SW)
					local x1 = min(r_east, c_NE+zf, c_SE-zf)
					local z0 = max(r_north, c_NW-xf, xf-c_NE)
					local z1 = min(r_south, c_SW+xf, c_SE-xf)
					xf = (xf-x0) / (x1-x0)
					zf = (zf-z0) / (z1-z0)
				elseif imax == 1 then
					xf = 0
				elseif imax == 2 then
					zf = 0
				elseif imax == 3 then
					xf = 1
				elseif imax == 4 then
					zf = 1
				elseif imax == 5 then
					xf, zf = 0, 0
				elseif imax == 6 then
					xf, zf = 1, 0
				elseif imax == 7 then
					xf, zf = 1, 1
				elseif imax == 8 then
					xf, zf = 0, 1
				end

				-- Determine elevation by interpolation
				local vdem = poly.dem
				local terrain_height = floor(0.5+interp(
					vdem[1],
					vdem[2],
					vdem[3],
					vdem[4],
					xf, zf
				))

				-- Spatial gradient of the interpolation
				local slope_x = zf*(vdem[3]-vdem[4]) + (1-zf)*(vdem[2]-vdem[1]) < 0
				local slope_z = xf*(vdem[3]-vdem[2]) + (1-xf)*(vdem[4]-vdem[1]) < 0
				local lake_id = 0
				if slope_x then
					if slope_z then
						lake_id = 3
					else
						lake_id = 2
					end
				else
					if slope_z then
						lake_id = 4
					else
						lake_id = 1
					end
				end
				local lake_height = max(floor(poly.lake[lake_id]), terrain_height)

				if imax > 0 and depth_factor_max > 0 then
					terrain_height = min(max(lake_height, sea_level) - floor(1+depth_factor_max*riverbed_slope), terrain_height)
				end

				terrain_height_map[i] = terrain_height
				lake_height_map[i] = lake_height
			else
				terrain_height_map[i] = MAP_BOTTOM
				lake_height_map[i] = MAP_BOTTOM
			end
			i = i + 1
		end
	end

	return terrain_height_map, lake_height_map
end

return heightmaps
