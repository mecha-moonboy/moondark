local EvolutionModel = dofile(mapgen_rivers.modpath .. '/terrainlib_lua/erosion.lua')
local twist = dofile(mapgen_rivers.modpath .. '/terrainlib_lua/twist.lua')

local blocksize = mapgen_rivers.settings.blocksize
local tectonic_speed = mapgen_rivers.settings.tectonic_speed

local np_base = table.copy(mapgen_rivers.noise_params.base)

local evol_params = mapgen_rivers.settings.evol_params

local time = mapgen_rivers.settings.evol_time
local time_step = mapgen_rivers.settings.evol_time_step
local niter = math.ceil(time/time_step)
time_step = time / niter

local function pregenerate(keep_loaded)
	local grid = mapgen_rivers.grid
	local size = grid.size

	local seed = tonumber(minetest.get_mapgen_setting("seed"))
	np_base.seed = (np_base.seed or 0) + seed

	local nobj_base = PerlinNoiseMap(np_base, {x=size.x, y=1, z=size.y})

	local dem = nobj_base:get_3d_map_flat({x=0, y=0, z=0})
	dem.X = size.x
	dem.Y = size.y

	local model = EvolutionModel(evol_params)
	model.dem = dem
	local ref_dem = model:define_isostasy(dem)

	local tectonic_step = tectonic_speed * time_step
	collectgarbage()
	for i=1, niter do
		minetest.log("info", "[mapgen_rivers] Iteration " .. i .. " of " .. niter)

		model:diffuse(time_step)
		model:flow()
		model:erode(time_step)
		if i < niter then
			if tectonic_step ~= 0 then
				nobj_base:get_3d_map_flat({x=0, y=tectonic_step*i, z=0}, ref_dem)
			end
			model:isostasy()
		end

		collectgarbage()
	end
	model:flow()

	local mfloor = math.floor
	local mmin, mmax = math.min, math.max
	local offset_x, offset_y = twist(model.dirs, model.rivers, 5)
	for i=1, size.x*size.y do
		offset_x[i] = mmin(mmax(offset_x[i]*256, -128), 127)
		offset_y[i] = mmin(mmax(offset_y[i]*256, -128), 127)
	end

	mapgen_rivers.write_map('dem', model.dem, 2)
	mapgen_rivers.write_map('lakes', model.lakes, 2)
	mapgen_rivers.write_map('dirs', model.dirs, 1)
	mapgen_rivers.write_map('rivers', model.rivers, 4)
	mapgen_rivers.write_map('offset_x', offset_x, 1)
	mapgen_rivers.write_map('offset_y', offset_y, 1)
	local sfile = io.open(mapgen_rivers.world_data_path .. 'size', "w")
	sfile:write(size.x..'\n'..size.y)
	sfile:close()

	if keep_loaded then
		grid.dem = model.dem
		grid.lakes = model.lakes
		grid.dirs = model.dirs
		grid.rivers = model.rivers
		grid.offset_x = offset_x
		grid.offset_y = offset_y
	end
	collectgarbage()
end

return pregenerate
