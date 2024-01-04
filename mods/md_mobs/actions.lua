local vec_dist = vector.distance

-- chase a target
function md_mobs.action_pursue(self, target, timeout, method, speed_factor, anim)
    local timer = timeout or 4
    local goal -- v3
    local function func(_self)
        -- there is a valid target
        local tgt_alv, los, tgt_pos = _self:get_target(target)
        if not tgt_alv then return true end

        self:animate(anim or "walk")

        goal = goal or tgt_pos
        timer = timer - _self.dtime -- counting down
        local safe = true

        -- confirm it is safe to follow goal
        if _self.max_fall and _self.max_fall > 0 then
            local pos = self.object:get_pos()
            if not pos then return end
            safe = _self:is_pos_safe(goal)
        end

        -- if there is line of sight, refresh goal position
        if los and vec_dist(goal, tgt_pos) > 3 then
            goal = tgt_pos
        end

        -- if it's not safe, or timer is out, or
        -- there is an obstacle to avoid, exit
        if timer <= 0 or not safe
        or _self:move_to(goal, method or "creatura:obstacle_avoidance", speed_factor or 0.5) then
            return true
        end
    end
    self:set_action(func)
end