local function fix_min_catchment(settings, is_global)
	local prefix = is_global and "mapgen_rivers_" or ""

	local min_catchment = settings:get(prefix.."min_catchment")
	if min_catchment then
		min_catchment = tonumber(min_catchment)
		local blocksize = tonumber(settings:get(prefix.."blocksize") or 15)
		settings:set(prefix.."min_catchment", tonumber(min_catchment) * blocksize*blocksize)
		local max_catchment = settings:get(prefix.."max_catchment")
		if max_catchment then
			max_catchment = tonumber(max_catchment)
			local wpower = math.log(2*blocksize)/math.log(max_catchment/min_catchment)
			settings:set(prefix.."river_widening_power", wpower)
		end
	end
end

local function fix_compatibility_minetest(settings)
	local previous_version = settings:get("mapgen_rivers_version") or "0.0"

	if previous_version == "0.0" then
		fix_min_catchment(settings, true)
	end
end

local function fix_compatibility_mapgen_rivers(settings)
	local previous_version = settings:get("version") or "0.0"

	if previous_version == "0.0" then
		fix_min_catchment(settings, false)
	end
end

return fix_compatibility_minetest, fix_compatibility_mapgen_rivers
