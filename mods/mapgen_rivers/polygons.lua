local modpath = mapgen_rivers.modpath
local mod_data_path = modpath .. 'river_data/'
if not io.open(mod_data_path .. 'size', 'r') then
	mod_data_path = modpath .. 'demo_data/'
end

local world_data_path = mapgen_rivers.world_data_path
minetest.mkdir(world_data_path)

dofile(modpath .. 'load.lua')

mapgen_rivers.grid = {}

local X = mapgen_rivers.settings.grid_x_size
local Z = mapgen_rivers.settings.grid_z_size

local function offset_converter(o)
	return (o + 0.5) * (1/256)
end

local load_all = mapgen_rivers.settings.load_all

-- Try to read file 'size'
local sfile = io.open(world_data_path..'size', 'r')
local first_mapgen = true
if sfile then
	X, Z = tonumber(sfile:read('*l')), tonumber(sfile:read('*l'))
	sfile:close()
	first_mapgen = false
end

if first_mapgen then
	-- Generate a map!!
	local pregenerate = dofile(mapgen_rivers.modpath .. '/pregenerate.lua')
	minetest.register_on_mods_loaded(function()
		minetest.log("action", '[mapgen_rivers] Generating grid, this may take a while...')
		pregenerate(load_all)

		if load_all then
			local offset_x = mapgen_rivers.grid.offset_x
			local offset_y = mapgen_rivers.grid.offset_y
			for i=1, X*Z do
				offset_x[i] = offset_converter(offset_x[i])
				offset_y[i] = offset_converter(offset_y[i])
			end
		end
	end)
end

-- if data not already loaded
if not (first_mapgen and load_all) then
	local load_map
	if load_all then
		load_map = mapgen_rivers.load_map
	else
		load_map = mapgen_rivers.interactive_loader
	end

	minetest.register_on_mods_loaded(function()
		if load_all then
			minetest.log("action", '[mapgen_rivers] Loading full grid')
		else
			minetest.log("action", '[mapgen_rivers] Loading grid as interactive loaders')
		end
		local grid = mapgen_rivers.grid

		grid.dem = load_map('dem', 2, true, X*Z)
		grid.lakes = load_map('lakes', 2, true, X*Z)
		grid.dirs = load_map('dirs', 1, false, X*Z)
		grid.rivers = load_map('rivers', 4, false, X*Z)

		grid.offset_x = load_map('offset_x', 1, true, X*Z, offset_converter)
		grid.offset_y = load_map('offset_y', 1, true, X*Z, offset_converter)
	end)
end

mapgen_rivers.grid.size = {x=X, y=Z}

local function index(x, z)
	return z*X+x+1
end

local blocksize = mapgen_rivers.settings.blocksize
local min_catchment = mapgen_rivers.settings.min_catchment
local max_catchment = mapgen_rivers.settings.max_catchment

local map_offset = {x=0, z=0}
if mapgen_rivers.settings.center then
	map_offset.x = blocksize*X/2
	map_offset.z = blocksize*Z/2
end

-- Localize for performance
local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs

local min_catchment = mapgen_rivers.settings.min_catchment / (blocksize*blocksize)
local wpower = mapgen_rivers.settings.river_widening_power
local wfactor = 1/(2*blocksize * min_catchment^wpower)
local function river_width(flow)
	flow = abs(flow)
	if flow < min_catchment then
		return 0
	end

	return min(wfactor * flow ^ wpower, 1)
end

local noise_heat -- Need a large-scale noise here so no heat blend
local elevation_chill = mapgen_rivers.settings.elevation_chill
local function get_temperature(x, y, z)
	local pos = {x=x, y=z}
	return noise_heat:get2d(pos) - y*elevation_chill
end

local glaciers = mapgen_rivers.settings.glaciers
local glacier_factor = mapgen_rivers.settings.glacier_factor

local init = false

-- On map generation, determine into which polygon every point (in 2D) will fall.
-- Also store polygon-specific data
local function make_polygons(minp, maxp)

	local grid = mapgen_rivers.grid
	local dem = grid.dem
	local lakes = grid.lakes
	local dirs = grid.dirs
	local rivers = grid.rivers

	local offset_x = grid.offset_x
	local offset_z = grid.offset_y

	if not init then
		if glaciers then
			noise_heat = minetest.get_perlin(mapgen_rivers.noise_params.heat)
		end
		init = true
	end

	local chulens = maxp.x - minp.x + 1

	local polygons = {}
	-- Determine the minimum and maximum coordinates of the polygons that could be on the chunk, knowing that they have an average size of 'blocksize' and a maximal offset of 0.5 blocksize.
	local xpmin, xpmax = max(floor((minp.x+map_offset.x)/blocksize - 0.5), 0), min(ceil((maxp.x+map_offset.x)/blocksize + 0.5), X-2)
	local zpmin, zpmax = max(floor((minp.z+map_offset.z)/blocksize - 0.5), 0), min(ceil((maxp.z+map_offset.z)/blocksize + 0.5), Z-2)

	-- Iterate over the polygons
	for xp = xpmin, xpmax do
		for zp=zpmin, zpmax do
			local iA = index(xp, zp)
			local iB = index(xp+1, zp)
			local iC = index(xp+1, zp+1)
			local iD = index(xp, zp+1)
			-- Extract the vertices of the polygon
			local poly_x = {
				(offset_x[iA]+xp)   * blocksize - map_offset.x,
				(offset_x[iB]+xp+1) * blocksize - map_offset.x,
				(offset_x[iC]+xp+1) * blocksize - map_offset.x,
				(offset_x[iD]+xp)   * blocksize - map_offset.x,
			}
			local poly_z = {
				(offset_z[iA]+zp)   * blocksize - map_offset.z,
				(offset_z[iB]+zp)   * blocksize - map_offset.z,
				(offset_z[iC]+zp+1) * blocksize - map_offset.z,
				(offset_z[iD]+zp+1) * blocksize - map_offset.z,
			}
			local polygon = {x=poly_x, z=poly_z, i={iA, iB, iC, iD}}

			local bounds = {} -- Will be a list of the intercepts of polygon edges for every Z position (scanline algorithm)
			-- Calculate the min and max Z positions 
			local zmin = max(floor(min(unpack(poly_z)))+1, minp.z)
			local zmax = min(floor(max(unpack(poly_z))), maxp.z)
			-- And initialize the arrays
			for z=zmin, zmax do
				bounds[z] = {}
			end

			local i1 = 4
			for i2=1, 4 do -- Loop on 4 edges
				local z1, z2 = poly_z[i1], poly_z[i2]
				-- Calculate the integer Z positions over which this edge spans
				local lzmin = floor(min(z1, z2))+1
				local lzmax = floor(max(z1, z2))
				if lzmin <= lzmax then -- If there is at least one position in it
					local x1, x2 = poly_x[i1], poly_x[i2]
					-- Calculate coefficient of the equation defining the edge: X=aZ+b
					local a = (x1-x2) / (z1-z2)
					local b = (x1 - a*z1)
					for z=max(lzmin, minp.z), min(lzmax, maxp.z) do
						-- For every Z position involved, add the intercepted X position in the table
						table.insert(bounds[z], a*z+b)
					end
				end
				i1 = i2
			end
			for z=zmin, zmax do
				-- Now sort the bounds list
				local zlist = bounds[z]
				table.sort(zlist)
				local c = floor(#zlist/2)
				for l=1, c do
					-- Take pairs of X coordinates: all positions between them belong to the polygon.
					local xmin = max(floor(zlist[l*2-1])+1, minp.x)
					local xmax = min(floor(zlist[l*2]), maxp.x)
					local i = (z-minp.z) * chulens + (xmin-minp.x) + 1
					for x=xmin, xmax do
						-- Fill the map at these places
						polygons[i] = polygon
						i = i + 1
					end
				end
			end

			local poly_dem = {dem[iA], dem[iB], dem[iC], dem[iD]}
			polygon.dem = poly_dem
			polygon.lake = {lakes[iA], lakes[iB], lakes[iC], lakes[iD]}

			-- Now, rivers.
			-- Load river flux values for the 4 corners
			local riverA = river_width(rivers[iA])
			local riverB = river_width(rivers[iB])
			local riverC = river_width(rivers[iC])
			local riverD = river_width(rivers[iD])
			if glaciers then -- Widen the river
				if get_temperature(poly_x[1], poly_dem[1], poly_z[1]) < 0 then
					riverA = min(riverA*glacier_factor, 1)
				end
				if get_temperature(poly_x[2], poly_dem[2], poly_z[2]) < 0 then
					riverB = min(riverB*glacier_factor, 1)
				end
				if get_temperature(poly_x[3], poly_dem[3], poly_z[3]) < 0 then
					riverC = min(riverC*glacier_factor, 1)
				end
				if get_temperature(poly_x[4], poly_dem[4], poly_z[4]) < 0 then
					riverD = min(riverD*glacier_factor, 1)
				end
			end

			polygon.river_corners = {riverA, 1-riverB, 2-riverC, 1-riverD}

			-- Flow directions
			local dirA, dirB, dirC, dirD = dirs[iA], dirs[iB], dirs[iC], dirs[iD]
			-- Determine the river flux on the edges, by testing dirs values
			local river_west = (dirA==1 and riverA or 0) + (dirD==3 and riverD or 0)
			local river_north = (dirA==2 and riverA or 0) + (dirB==4 and riverB or 0)
			local river_east = 1 - (dirB==1 and riverB or 0) - (dirC==3 and riverC or 0)
			local river_south = 1 - (dirD==2 and riverD or 0) - (dirC==4 and riverC or 0)

			polygon.rivers = {river_west, river_north, river_east, river_south}
		end
	end

	return polygons
end

return make_polygons
