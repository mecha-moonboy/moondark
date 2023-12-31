--[[

- generate skyboxes from layered textures
- track seasons, moon phases, and messenger orbits

How I want to control it:
- set/get planet
    - various bonuses
- set/get season
    - heat
    - humidity
    - sun size
- set/get moon
    - mob activity
- set/get weather
    - rain
    - thunder/lightning
    - drought
    - blizzard
    - auroras
    - cloudy
    - sunny
    - glorious
    - acid

]]


local meta = minetest.get_mod_storage()

local moon_phase = 1 -- Day (30 min)
local moon_cycle = 1 -- Month (4 hrs)(8 days)
local year = 1       -- Year (24 hrs)(6 months, 48 days)
local first_planet_orbit = 1 -- three times a year (2 moon cycles)

local curr_day
function md_astro.do_step(dtime)
    --timer = timer + dtime
    if curr_day == minetest.get_day_count() then
        return
    end
    curr_day = minetest.get_day_count()

    md_astro.increment_moon()
end

-- increment the moon and do any phase start behaviour and messages
function md_astro.increment_moon()
    moon_phase = moon_phase + 1
    if moon_phase > 8 then
        moon_phase = 1
        -- increment moon cycle
    end

    -- set moon texture for players
    md_astro.set_player_moons(moon_phase)
end

function md_astro.set_player_moons(phase)
    local players = minetest.get_connected_players()
    for _, player in ipairs(players) do
        player:set_moon({
            texture = "moon_".. phase ..".png"
        })
    end
end

function md_astro.set_player_sun(state)
    local players = minetest.get_connected_players()
    for _, player in ipairs(players) do
        player:set_moon({
            texture = "sun_".. state ..".png"
        })
    end
end

function md_astro.save_moon()
    meta:set_int("moon_phase", moon_phase)
end

function md_astro.load_moon()
    moon_phase = meta.get_int("moon_phase")
end

function md_astro.save_moon_cycle()
    meta:set_int("moon_cycle", moon_cycle)
end

function md_astro.load_moon_cycle()
    moon_cycle = meta.get_int("moon_cycle")
end