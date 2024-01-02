local vec_dist = vector.distance

function md_mobs.action_pursue(self, target, timeout, method, speed_factor, anim)
    local timer = timeout or 4
    local goal
    local function func(_self)
        local tgt_alv, los, tgt_pos = _self:get_target(target)
        if not tgt_alv then return true end

        goal = goal or tgt_pos
        timer = timer - _self.dtime
        self:animate(anim or "walk")
        local safe = true
        if _self.max_fall and _self.max_fall > 0 then
            local pos = self.object:get_pos()
            if not pos then return end
            safe = _self:is_pos_safe(goal)
        end
        if los and vec_dist(goal, tgt_pos) > 3 then
            goal = tgt_pos
        end
        if timer <= 0 or not safe
        or _self:move_to(goal, method or "creatura:obstacle_avoidance", speed_factor or 0.5) then
            return true
        end
    end
    self:set_action(func)
end