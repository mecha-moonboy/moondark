-- Math --

local abs = math.abs
local atan2 = math.atan2
local cos = math.cos
local min = math.min
local max = math.max
local floor = math.floor
local pi = math.pi
local pi2 = pi * 2
local sin = math.sin
local rad = math.rad
local random = math.random

local function diff(a, b) -- Get difference between 2 angles
	return atan2(sin(b - a), cos(b - a))
end

local function clamp(val, minn, maxn)
	if val < minn then
		val = minn
	elseif maxn < val then
		val = maxn
	end
	return val
end

-- Vector Math --

local vec_add, vec_dot, vec_dir, vec_dist, vec_multi, vec_normal,
	vec_round, vec_sub = vector.add, vector.dot, vector.direction, vector.distance,
	vector.multiply, vector.normalize, vector.round, vector.subtract

local dir2yaw = minetest.dir_to_yaw
local yaw2dir = minetest.yaw_to_dir

-- Function to calculate dot product of two vectors
local function dot_product(v1, v2)
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
end

-- Function to calculate the direction vector from pos1 to pos2
local function calculate_direction(pos1, pos2)
	--minetest.log("Dir: " .. vector.direction(pos1, pos2):to_string())
    return vector.direction(pos1, pos2)
end

-- Function to calculate whether the whale is facing towards pos2 or away from it
local function is_facing_whale(yaw, pos1, pos2)
    -- Calculate the direction vector from pos1 to pos2
    local direction = calculate_direction(pos1, pos2)

    -- Convert yaw angle to a unit vector representing the forward direction of the whale
    local forward = {
        x = math.sin(math.rad(yaw)),
        y = 0,  -- Assuming the whale doesn't pitch up or down
        z = math.cos(math.rad(yaw))
    }

    -- Calculate the dot product between the direction vector and the whale's forward vector
    local dot = dot_product(direction, forward)

    -- If dot product is positive, whale is facing towards pos2, otherwise, it's facing away
    if dot > 0.6 then
        return true -- Whale is facing towards pos2
    else
        return false -- Whale is facing away from pos2
    end
end

local function get_obstacle(pos, water)
	local pos2 = {x = pos.x, y = pos.y, z = pos.z}
	local n_def = creatura.get_node_def(pos2)
	if n_def.walkable
	or (water and (n_def.groups.liquid or 0) > 0) then
		pos2.y = pos.y + 1
		n_def = creatura.get_node_def(pos2)
		local col_max = n_def.walkable or (water and (n_def.groups.liquid or 0) > 0)
		pos2.y = pos.y - 1
		local col_min = col_max and (n_def.walkable or (water and (n_def.groups.liquid or 0) > 0))
		if col_min then
			return pos
		else
			pos2.y = pos.y + 1
			return pos2
		end
	end
end

function md_fauna.get_steering_context(self, goal, steer_dir, interest, danger, range)
	local pos = self.object:get_pos()
	if not pos then return end
	pos = vec_round(pos)
	local width = self.width or 0.5

	local check_pos = vec_add(pos, steer_dir)
	local collision = get_obstacle(check_pos)
	local unsafe_pos = not collision and not self:is_pos_safe(check_pos) and check_pos

	if collision
	or unsafe_pos then
		local dir2goal = vec_normal(vec_dir(pos, goal))
		local dir2col = vec_normal(vec_dir(pos, collision or unsafe_pos))
		local dist2col = vec_dist(pos, collision or unsafe_pos) - width
		local dot_score = vec_dot(dir2col, dir2goal)
		local dist_score = (range - dist2col) / range
		interest = interest - dot_score
		danger = dist_score
	end
	return interest, danger
end

function md_fauna.obstacle_avoidance(self, goal, water)
	local steer_method = water and creatura.get_context_small_aquatic or md_fauna.get_steering_context
	local dir = creatura.calc_steering(self, goal, steer_method)

	local lift_method = water and creatura.get_avoidance_lift_aquatic or creatura.get_avoidance_lift
	local lift = lift_method(self, vec_add(self.stand_pos, dir), 2)
	dir.y = (lift ~= 0 and lift) or dir.y

	return dir
end

creatura.register_movement_method("md_fauna:steer_no_gravity", function(self)
	local steer_to
	local steer_int = 0

	local radius = 2 -- Arrival Radius

	self:set_gravity(0)
	local function func(_self, goal, speed_factor)
		-- Vectors
		local pos = self.object:get_pos()
		if not pos or not goal then return end

		local dist = vec_dist(pos, goal)
		local dir = vec_dir(pos, goal)

		-- Movement Params
		local vel = self.speed * speed_factor
		local turn_rate = self.turn_rate
		local mag = min(radius - ((radius - dist) / 1), 1)
		vel = vel * mag

		-- Steering
		steer_int = (steer_int > 0 and steer_int - _self.dtime) or 1 / max(vel, 1)
		steer_to = steer_int <= 0 and md_fauna.obstacle_avoidance(_self, goal, _self.max_breath == 0) or steer_to

		-- Apply Movement
		_self:turn_to(minetest.dir_to_yaw(steer_to or dir), turn_rate)
		_self:set_forward_velocity(vel)
		_self:set_vertical_velocity(dir.y * vel)
	end
	return func
end)

creatura.register_movement_method("md_fauna:steer", function(self)
	local steer_to
	local steer_int = 0

	local radius = 2 -- Arrival Radius

	self:set_gravity(-9.8)
	local function func(_self, goal, speed_factor)
		-- Vectors
		local pos = self.object:get_pos()
		if not pos or not goal then return end

		local dist = vec_dist(pos, goal)
		local dir = vec_dir(pos, goal)

		-- Movement Params
		local vel = self.speed * speed_factor
		local turn_rate = self.turn_rate
		local mag = min(radius - ((radius - dist) / 1), 1)
		vel = vel * mag

		-- Steering
		steer_int = (steer_int > 0 and steer_int - _self.dtime) or 1 / max(vel, 1)
		steer_to = steer_int <= 0 and md_fauna.obstacle_avoidance(_self, goal) or steer_to

		-- Apply Movement
		_self:turn_to(minetest.dir_to_yaw(steer_to or dir), turn_rate)
		_self:set_forward_velocity(vel)
	end
	return func
end)
-- Behaviors

creatura.register_utility("md_fauna:die", function(self)
	local timer = 1.5
	local init = false
	local function func(_self)
		if not init then
			_self:play_sound("death")
			creatura.action_fallover(_self)
			init = true
		end
		timer = timer - _self.dtime
		if timer <= 0 then
			local pos = _self.object:get_pos()
			if not pos then return end
			minetest.add_particlespawner({
				amount = 8,
				time = 0.25,
				minpos = {x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1},
				maxpos = {x = pos.x + 0.1, y = pos.y + 0.1, z = pos.z + 0.1},
				minacc = {x = 0, y = 2, z = 0},
				maxacc = {x = 0, y = 3, z = 0},
				minvel = {x = random(-1, 1), y = -0.25, z = random(-1, 1)},
				maxvel = {x = random(-2, 2), y = -0.25, z = random(-2, 2)},
				minexptime = 0.75,
				maxexptime = 1,
				minsize = 4,
				maxsize = 4,
				texture = "creatura_smoke_particle.png",
				animation = {
					type = 'vertical_frames',
					aspect_w = 4,
					aspect_h = 4,
					length = 1,
				},
				glow = 1
			})
			creatura.drop_items(_self)
			_self.object:remove()
		end
	end
	self:set_utility(func)
end)

creatura.register_utility("md_fauna:basic_seek_pos", function(self, pos2, timeout)
	timeout = timeout or 3
	local function func(mob)
		local pos = mob.object:get_pos()
		if not pos or not pos2 then return true end

		if not mob:get_action() then
			local anim = (mob.animations["run"] and "run") or "walk"
			md_fauna.action_walk(mob, 1, 1, anim, pos2)
		end

		timeout = timeout - mob.dtime
		if timeout <= 0 then
			return true
		end
	end
	self:set_utility(func)
end)

creatura.register_utility("md_fauna:swim_wander", function(self)
	local move_chance = 2
	local idle_max = 4

	local function func(mob)
		if not mob:get_action() then -- there isn't another action queued
			if not mob.in_liquid then -- this mob is not in liquid
				--minetest.log("Not in liquid")
				local mob_pos = mob.object:get_pos()
				local water_nodes = minetest.find_nodes_in_area(vec_sub(mob_pos, 10), vec_add(mob_pos, 10), "moondark:water_source")
				local water_node = water_nodes[random(#water_nodes)]
				local obj = mob.object
				-- no water nearby, no mob to move
				if not water_node or not obj then
					-- there is no water node, just roll
					--creatura.action_idle(mob, 1, "roll")
					--return
				elseif is_facing_whale(obj:get_yaw() * (180 / math.pi), obj:get_pos(), water_node) then
					md_fauna.action_walk(mob, 1, 1, "roll", water_node)
					return
				else
					md_fauna.action_idle_turn(mob, 1, "roll", water_node) -- do idle action
				end

				-- if there is a water node within the area
				--minetest.log("There should be a water node nearby")
			end

			if not mob.idle_in_water -- mob is not idle in water
			or random(move_chance) < 2 then
				md_fauna.action_swim(mob, 0.5, mob.max_depth) -- do swim
			else
				md_fauna.action_float(mob, random(idle_max), "float") -- do float
			end
		end
	end
	self:set_utility(func)
end)

-- Actions --
function md_fauna.action_walk(self, time, speed, animation, pos2)
	local timeout = time or 3
	local speed_factor = speed or 0.5
	local anim = animation or "walk"

	local wander_radius = 2

	local dir = pos2 and vec_dir(self.stand_pos, pos2)
	local function func(mob)
		local pos, yaw = mob.object:get_pos(), mob.object:get_yaw()
		if not pos or not yaw then return true end

		dir = pos2 and vec_dir(pos, pos2) or minetest.yaw_to_dir(yaw)

		local wander_point = vec_add(pos, vec_multi(dir, wander_radius + 0.5))
		local goal = vec_add(wander_point, vec_multi(minetest.yaw_to_dir(random(pi2)), wander_radius))

		local safe = true

		if mob.max_fall then
			safe = mob:is_pos_safe(goal)
		end

		if timeout <= 0
		or not safe
		or mob:move_to(goal, "md_fauna:steer", speed_factor) then
			mob:halt()
			return true
		end

		timeout = timeout - mob.dtime
		if timeout <= 0 then return true end

		mob:animate(anim)
	end
	self:set_action(func)
end

function md_fauna.action_idle_turn(self, time, anim, pos2)
	local timer = time
	local function func(_self)
		_self:move_to(pos2, "md_fauna:steer")
		_self:set_gravity(-9.8)
		_self:halt()
		_self:animate(anim or "stand")
		timer = timer - _self.dtime
		if timer <= 0 then
			return true
		end
	end
	self:set_action(func)
end

md_fauna.mob_ai = {}

md_fauna.mob_ai.swim_wander = {
	utility = "md_fauna:swim_wander",
	step_delay = 0.25,
	get_score = function(self)
		return 0.1, {self}
	end
}

function md_fauna.action_swim(self, time, depth, speed, animation, pos2)
	local timeout = time or 3
	local speed_factor = speed or 0.5
	local anim = animation or "swim"
	local depth_factor = depth or 0

	local wander_radius = 2

	local function func(mob)
		local pos, yaw = mob.object:get_pos(), mob.object:get_yaw()
		if not pos or not yaw then return true end

		if not mob.in_liquid then
			return true
		end

		local steer_direction = pos2 and vec_dir(pos, pos2)

		if not steer_direction then
			local wander_point = {
				x = pos.x + -sin(yaw) * (wander_radius + 0.5),
				y = pos.y,
				z = pos.z + cos(yaw) * (wander_radius + 0.5)
			}

			local wander_angle = random(pi2)

			steer_direction = vec_dir(pos, {
				x = wander_point.x + -sin(wander_angle) * wander_radius,
				y = wander_point.y + (random(-10, 10) / 10),
				z = wander_point.z + cos(wander_angle) * wander_radius
			})
		end

		-- Boids
		local boid_dir = mob.uses_boids and creatura.get_boid_dir(mob)
		if boid_dir then
			steer_direction = {
				x = (steer_direction.x + boid_dir.x) / 2,
				y = (steer_direction.y + boid_dir.y) / 2,
				z =	(steer_direction.z + boid_dir.z) / 2
			}
		end

		local goal = vec_add(pos, vec_multi(steer_direction, mob.width + 2))

		if pos.y > depth_factor and steer_direction.y > 0 then
			steer_direction.y = -steer_direction.y
		end

		if timeout <= 0
		or mob:move_to(goal, "md_fauna:steer_no_gravity", speed_factor) then
			mob:halt()
			return true
		end

		timeout = timeout - mob.dtime
		if timeout <= 0 then return true end
		mob:animate(anim)
	end
	self:set_action(func)
end

function md_fauna.action_float(self, time, anim)
	local timer = time
	local function func(_self)
		_self:set_gravity(-0.14)
		_self:halt()
		_self:animate(anim or "float")
		timer = timer - _self.dtime
		if timer <= 0 then
			return true
		end
	end
	self:set_action(func)
end