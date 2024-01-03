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
local month_length = 8
local year_length = 8

local meta = minetest.get_mod_storage()

-- Loading time data from meta.
local curr_day = meta:get_int("curr_day") or 0
local moon_phase = meta:get_int("moon_phase") or 1 -- Day (20 min)
local moon_cycle = meta:get_int("moon_cycle") or 1 -- Month (160 minutes)(8 days)
local year = meta:get_int("year") or 1       -- Year (16hrs)(8 months, 64 days)

-- Execute this on globalstep.
function md_astro.do_step()
    -- iterate the day and moon phase
    if curr_day == minetest.get_day_count() then
        return
    end
    curr_day = minetest.get_day_count()
    md_astro.increment_moon_phase()
end

-- Increment the moon and
-- do any phase start behaviour.
function md_astro.increment_moon_phase()
    moon_phase = moon_phase + 1
    if moon_phase > month_length then
        moon_phase = 1
        md_astro.increment_moon_cycle()
    end

    -- set moon texture for players
    md_astro.set_player_moons_all(moon_phase)
end

-- Increment the month(moon cycle) and
-- do any month start behaviour.
function md_astro.increment_moon_cycle()

    moon_cycle = moon_cycle + 1
    if moon_cycle > year_length then
        moon_cycle = 1
    end

    if moon_cycle == 1 or moon_cycle == 2 then
        md_astro.set_player_suns_all("default")
    elseif moon_cycle == 3 or moon_cycle == 4 then
        md_astro.set_player_suns_all("summer")
    elseif moon_cycle == 5 or moon_cycle == 6 then
        md_astro.set_player_suns_all("default")
    elseif moon_cycle == 7 or moon_cycle == 8 then
        md_astro.set_player_suns_all("winter")
    end
end

-- Set a specific player's moon.
function md_astro.set_player_moon(player)
    player:set_moon({
        texture = "moon_" .. moon_phase .. ".png"
    })
end

-- Set a specific player's sun.
function md_astro.set_player_sun(player)
    local phase
    if moon_cycle == 1 or moon_cycle == 2 then
        phase = "default"
    elseif moon_cycle == 3 or moon_cycle == 4 then
        phase = "summer"
    elseif moon_cycle == 5 or moon_cycle == 6 then
        phase = "default"
    elseif moon_cycle == 7 or moon_cycle == 8 then
        phase = "winter"
    end

    if not phase then return end
    player:set_sun({
        texture = "sun_" .. phase .. ".png"
    })
end

-- Refresh all player's moon visuals.
function md_astro.set_player_moons_all(phase)
    local players = minetest.get_connected_players()
    for _, player in ipairs(players) do
        player:set_moon({
            texture = "moon_".. phase ..".png"
        })
    end
end

-- Refresh all player's sun visuals.
function md_astro.set_player_suns_all(state)
    local players = minetest.get_connected_players()
    for _, player in ipairs(players) do
        player:set_sun({
            texture = "sun_".. state ..".png"
        })
    end
end

-- Duh.
function md_astro.save_state()
    meta:set_int("curr_day", curr_day)
    meta:set_int("moon_phase", moon_phase)
    meta:set_int("moon_cycle", moon_phase)
    meta:set_int("year", moon_phase)
end