-- erosion.lua

-- This is the main file of terrainlib_lua. It registers the EvolutionModel object and some of the 

local function erode(model, time)
	-- Apply river erosion on the model
	-- Erosion model is based on the simplified version of the stream-power law Ey = K×A^m×S
	-- where Ey is the vertical erosion speed, A catchment area of the river, S slope along the river, m and K local constants.
	-- It is equivalent to considering a horizontal erosion wave travelling at Ex = K×A^m, and this latter approach allows much greather time steps so it is used here.
	-- For each point, instead of moving upstream and see what point the erosion wave would reach, we move downstream and see from which point the erosion wave would reach the given point, then we can set the elevation.
	local mmin, mmax = math.min, math.max
	local dem = model.dem
	local dirs = model.dirs
	local lakes = model.lakes
	local rivers = model.rivers
	local sea_level = model.params.sea_level
	local K = model.params.K
	local m = model.params.m
	local X, Y = dem.X, dem.Y
	local scalars = type(K) == "number" and type(m) == "number"

	local erosion_time
	if model.params.variable_erosion then
		erosion_time = {}
	else
		erosion_time = model.erosion_time or {}
	end

	if scalars then
		for i=1, X*Y do
			local etime = 1 / (K*rivers[i]^m) -- Inverse of erosion speed (Ex); time needed for the erosion wave to move through the river section.
			erosion_time[i] = etime
			lakes[i] = mmax(lakes[i], dem[i], sea_level) -- Use lake/sea surface if higher than ground level, because rivers can not erode below.
		end
	else
		for i=1, X*Y do
			local etime = 1 / (K[i]*rivers[i]^m[i])
			erosion_time[i] = etime
			lakes[i] = mmax(lakes[i], dem[i], sea_level)
		end
	end

	for i=1, X*Y do
		local iw = i
		local remaining = time
		local new_elev
		while true do
			-- Explore downstream until we find the point 'iw' from which the erosion wave will reach 'i'
			local inext = iw
			local d = dirs[iw]

			-- Follow the river downstream (move 'iw')
			if d == 0 then -- If no flow direction, we reach the border of the map: set elevation to the latest node's elev and abort.
				new_elev = lakes[iw]
				break
			elseif d == 1 then
				inext = iw+X
			elseif d == 2 then
				inext = iw+1
			elseif d == 3 then
				inext = iw-X
			elseif d == 4 then
				inext = iw-1
			end

			local etime = erosion_time[iw]
			if remaining <= etime then -- We have found the node from which the erosion wave will take 'time' to arrive to 'i'.
				local c = remaining / etime
				new_elev = (1-c) * lakes[iw] + c * lakes[inext] -- Interpolate linearly between the two nodes
				break
			end

			remaining = remaining - etime -- If we still don't reach the target time, decrement time and move to next point.
			iw = inext
		end

		dem[i] = mmin(dem[i], new_elev)
	end
end

local function diffuse(model, time)
	-- Apply diffusion using finite differences methods
	-- Adapted for small radiuses
	local mmax = math.max
	local dem = model.dem
	local X, Y = dem.X, dem.Y
	local d = model.params.d
	-- 'd' is equal to 4 times the diffusion coefficient
	local dmax = d
	if type(d) == "table" then
		dmax = -math.huge
		for i=1, X*Y do
			dmax = mmax(dmax, d[i])
		end
	end

	local diff = dmax * time
	-- diff should never exceed 1 per iteration.
	-- If needed, we will divide the process in enough iterations so that 'ddiff' is below 1.
	local niter = math.floor(diff) + 1
	local ddiff = diff / niter

	local temp = {}
	for n=1, niter do
		local i = 1
		for y=1, Y do
			local iN = (y==1) and 0 or -X
			local iS = (y==Y) and 0 or X
			for x=1, X do
				local iW = (x==1) and 0 or -1
				local iE = (x==X) and 0 or 1
				-- Laplacian Δdem × 1/4
				temp[i] = (dem[i+iN]+dem[i+iE]+dem[i+iS]+dem[i+iW])*0.25 - dem[i]
				i = i + 1
			end
		end

		for i=1, X*Y do
			dem[i] = dem[i] + temp[i]*ddiff
		end
	end
end

local modpath = ""
if minetest then
	if minetest.global_exists('mapgen_rivers') then
		modpath = mapgen_rivers.modpath .. "terrainlib_lua/"
	else
		modpath = minetest.get_modpath(minetest.get_current_modname()) .. "terrainlib_lua/"
	end
end

local rivermapper = dofile(modpath .. "rivermapper.lua")
local gaussian = dofile(modpath .. "gaussian.lua")

local function flow(model)
	model.dirs, model.lakes = rivermapper.flow_routing(model.dem, model.dirs, model.lakes, 'semirandom')
	model.rivers = rivermapper.accumulate(model.dirs, model.rivers)
end

local function uplift(model, time)
	-- Raises the terrain according to uplift rate (model.params.uplift)
	local dem = model.dem
	local X, Y = dem.X, dem.Y
	local uplift_rate = model.params.uplift
	if type(uplift_rate) == "number" then
		local uplift_total = uplift_rate * time
		for i=1, X*Y do
			dem[i] = dem[i] + uplift_total
		end
	else
		for i=1, X*Y do
			dem[i] = dem[i] + uplift_rate[i]*time
		end
	end
end

local function noise(model, time)
	-- Adds noise to the terrain according to noise depth (model.params.noise)
	local random = math.random
	local dem = model.dem
	local noise_depth = model.params.noise * 2 * time
	local X, Y = dem.X, dem.Y
	for i=1, X*Y do
		dem[i] = dem[i] + (random()-0.5) * noise_depth
	end
end

-- Isostasy
-- This is the geological phenomenon that makes the lithosphere "float" over the underlying layers.
-- One of the key implications is that when a very large mass is removed from the ground, the lithosphere reacts by moving upward. This compensation only occurs at large scale (as the lithosphere is not flexible enough for small scale adjustments) so the implementation is using a very large-window Gaussian blur of the elevation array.

-- This implementation is quite simplistic, it does not do a mass balance of the lithosphere as this would introduce too many parameters. Instead, it defines a reference equilibrium elevation, and the ground will react toward this elevation (at the scale of the gaussian window).
-- A change in reference isostasy during the run can also be used to simulate tectonic forcing, like making a new mountain range appear.
local function define_isostasy(model, ref, link)
	ref = ref or model.dem
	if link then
		model.isostasy_ref = ref
		return
	end

	local X, Y = ref.X, ref.Y
	local ref2 = model.isostasy_ref or {X=X, Y=Y}
	model.isostasy_ref = ref2
	for i=1, X*Y do
		ref2[i] = ref[i]
	end

	return ref2
end

-- Apply isostasy
local function isostasy(model)
	local dem = model.dem
	local X, Y = dem.X, dem.Y
	local temp = {X=X, Y=Y}
	local ref = model.isostasy_ref
	for i=1, X*Y do
		temp[i] = ref[i] - dem[i] -- Compute the difference between the ground level and the target level
	end

	-- Blur the difference map using Gaussian blur
	gaussian.gaussian_blur_approx(temp, model.params.compensation_radius, 4)
	for i=1, X*Y do
		dem[i] = dem[i] + temp[i] -- Apply the difference
	end
end

local evol_model_mt = {
	erode = erode,
	diffuse = diffuse,
	flow = flow,
	uplift = uplift,
	noise = noise,
	isostasy = isostasy,
	define_isostasy = define_isostasy,
}

evol_model_mt.__index = evol_model_mt

local defaults = {
	K = 1,
	m = 0.5,
	d = 1,
	variable_erosion = false,
	sea_level = 0,
	uplift = 10,
	noise = 0.001,
	compensation_radius = 50,
}

local function EvolutionModel(params)
	params = params or {}
	local o = {params = params}
	for k, v in pairs(defaults) do
		if params[k] == nil then
			params[k] = v
		end
	end
	o.dem = params.dem
	return setmetatable(o, evol_model_mt)
end

return EvolutionModel
