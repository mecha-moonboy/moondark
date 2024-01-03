local mt, settings = minetest, minetest.settings
local max_distance = tonumber(settings:get "moondark.max_distance") or 40
local max_radius = tonumber(settings:get "moondark.max_radius") or 1
local delay = tonumber(settings:get "moondark.delay") or 0.01
local reverse = settings:get_bool("moondark.reverse_modifiers", false)
local only_upward = settings:get_bool("moondark.only_upward", true)
local prevent_break = settings:get_bool("moondark.prevent_tool_break", true)
local S = mt.get_translator(mt.get_current_modname())
local privilege = {
    description = S "Player can fell trees quickly."
}

-- check whether any modifying buttons are pressed
---@param player mt.PlayerObjectRef
---@return boolean
local function check_modifiers(player)
    local control = player:get_player_control() or {}
    if reverse then
        if not control.aux1 and not control.sneak then
            return false
        end
    else
        if control.aux1 or control.sneak then
            return false
        end
    end
    return true
end


---@param pos mt.Vector
---@param oldnode mt.Node
---@param digger mt.PlayerObjectRef
local function chop_recursive(pos, oldnode, digger)
    -- CATCHES --
    -- cancel if no player
    if not digger or not digger:is_player() then
        return
    end
    -- no modifying keys for digging (sneak, etc.)
    if not check_modifiers(digger) then
        return
    end
    local node_groups = mt.registered_nodes[oldnode.name].groups
    -- no node groups or none that are wood
    if not node_groups or not node_groups.wooden then
        return
    end
    -- no tool?
    local tool = digger:get_wielded_item()
    if not tool or not tool:get_definition().groups.axe then
        return
    end
    -- prevent the axe from breaking when durability is low
    if prevent_break then
        local wear = tool:get_wear()
        local tool_capabilities = tool:get_tool_capabilities()
        local dig_params = mt.get_dig_params(node_groups, tool_capabilities, wear)
        if wear >= 65536 - dig_params.wear * 9 then
            return
        end
    end
    -- he dead
    if digger:get_hp() == 0 then
        return
    end
    -- no privs?
    local d = delay
    if not mt.check_player_privs(digger, "lumberjack") then
        d = d * 100
    end
    -- EXECUTION --
    mt.after(d, function()
        local next_pos = mt.find_node_near(pos, max_radius, oldnode.name)
        if not next_pos then
            return
        end
        if only_upward and next_pos.y < pos.y then
            return
        end
        local digger_pos = digger:get_pos()
        if not digger_pos then
            return
        end
        if pos:distance(digger_pos) > max_distance then
            return
        end
        mt.node_dig(next_pos, mt.get_node(next_pos), digger)
        chop_recursive(pos, oldnode, digger)
    end)
end

-- register event and privilege
mt.register_privilege("lumberjack", privilege)
mt.register_on_dignode(chop_recursive)
