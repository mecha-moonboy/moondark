local mtsettings = minetest.settings
local mgrsettings = Settings(minetest.get_worldpath() .. '/mapgen_rivers.conf')

mapgen_rivers.version = "1.0.2"

local previous_version_mt = mtsettings:get("mapgen_rivers_version") or "0.0"
local previous_version_mgr = mgrsettings:get("version") or "0.0"

if mapgen_rivers.version ~= previous_version_mt or mapgen_rivers.version ~= previous_version_mgr then
	local compat_mt, compat_mgr = dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/compatibility.lua")
	if mapgen_rivers.version ~= previous_version_mt then
		compat_mt(mtsettings)
	end
	if mapgen_rivers.version ~= previous_version_mgr then
		compat_mgr(mgrsettings)
	end
end

mtsettings:set("mapgen_rivers_version", mapgen_rivers.version)
mgrsettings:set("version", mapgen_rivers.version)

function mapgen_rivers.define_setting(name, dtype, default)
	if dtype == "number" or dtype == "string" then
		local v = mgrsettings:get(name)
		if v == nil then
			v = mtsettings:get('mapgen_rivers_' .. name)
			if v == nil then
				v = default
			end
			mgrsettings:set(name, v)
		end
		if dtype == "number" then
			return tonumber(v)
		else
			return v
		end
	elseif dtype == "bool" then
		local v = mgrsettings:get_bool(name)
		if v == nil then
			v = mtsettings:get_bool('mapgen_rivers_' .. name)
			if v == nil then
				v = default
			end
			mgrsettings:set_bool(name, v)
		end
		return v
	elseif dtype == "noise" then
		local v = mgrsettings:get_np_group(name)
		if v == nil then
			v = mtsettings:get_np_group('mapgen_rivers_' .. name)
			if v == nil then
				v = default
			end
			mgrsettings:set_np_group(name, v)
		end
		return v
	end
end

local def_setting = mapgen_rivers.define_setting

mapgen_rivers.settings = {
	center = def_setting('center', 'bool', true),
	blocksize = def_setting('blocksize', 'number', 15),
	sea_level = tonumber(minetest.get_mapgen_setting('water_level')),
	min_catchment = def_setting('min_catchment', 'number', 3600),
	river_widening_power = def_setting('river_widening_power', 'number', 0.5),
	riverbed_slope = def_setting('riverbed_slope', 'number', 0.4),
	distort = def_setting('distort', 'bool', true),
	biomes = def_setting('biomes', 'bool', true),
	glaciers = def_setting('glaciers', 'bool', false),
	glacier_factor = def_setting('glacier_factor', 'number', 8),
	elevation_chill = def_setting('elevation_chill', 'number', 0.25),

	grid_x_size = def_setting('grid_x_size', 'number', 1000),
	grid_z_size = def_setting('grid_z_size', 'number', 1000),
	evol_params = {
		K = def_setting('river_erosion_coef', 'number', 0.5),
		m = def_setting('river_erosion_power', 'number', 0.4),
		d = def_setting('diffusive_erosion', 'number', 0.5),
		compensation_radius = def_setting('compensation_radius', 'number', 50),
	},
	tectonic_speed = def_setting('tectonic_speed', 'number', 70),
	evol_time = def_setting('evol_time', 'number', 10),
	evol_time_step = def_setting('evol_time_step', 'number', 1),

	load_all = mtsettings:get_bool('mapgen_rivers_load_all')
}

local function write_settings()
	mgrsettings:write()
end

minetest.register_on_mods_loaded(write_settings)
minetest.register_on_shutdown(write_settings)
