local vec_dist = vector.distance

creatura.register_utility("md_mobs:follow_player", function(self, player, force)
    local width = self.width
    local function func(_self)
        -- get position, cancel if nil
        local pos = _self.object:get_pos()
        if not pos then return end

        local plr_alv, _, plr_pos = _self:get_target(player)
        if not plr_alv or (not _self:follow_wielded_item(player) and not force)
        then return true end

        local dist = vec_dist(pos, plr_pos)
        if not _self:get_action() then
            local anim = ""
            local speed = 0.5
            if dist > self.tracking_range * 0.5 then
                -- anim = ""
                speed = 1
            end

            if dist > width + 2
            and _self:is_pos_safe(plr_pos) then
                md_mobs.action_pursue(_self, player, 1, "creatura:steer_small", speed, anim)
            else creatura.action_idle(_self, 1) end
        end
    end
    self:set_utility(func)
end)