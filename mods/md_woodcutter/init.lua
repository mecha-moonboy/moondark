local mt, ms = minetest, minetest.settings
local max_distance = tonumber(ms:get "simple_woodcutter.max_distance") or 40
local max_radius = tonumber(ms:get "simple_woodcutter.max_radius") or 1
local delay = tonumber(ms:get "simple_woodcutter.delay") or 0.01
local reverse = ms:get_bool("simple_woodcutter.reverse_modifiers", false)
local only_upward = ms:get_bool("simple_woodcutter.only_upward", true)
local prevent_break = ms:get_bool("simple_woodcutter.prevent_tool_break", true)
local S = mt.get_translator(mt.get_current_modname())
local privilege = { description = S "Player can fell trees quickly." }

---@param player mt.PlayerObjectRef
---@return boolean
local function check_modifiers(player)
  local control = player:get_player_control() or {}
  if reverse then
    if not control.aux1 and not control.sneak then return false end
  else
    if control.aux1 or control.sneak then return false end
  end
  return true
end

---@param pos mt.Vector
---@param oldnode mt.Node
---@param digger mt.PlayerObjectRef
local function chop_recursive(pos, oldnode, digger)
  if not digger or not digger:is_player() then return end -- cancel if no player
  if not check_modifiers(digger) then return end -- no modifiers for digging
  local node_groups = mt.registered_nodes[oldnode.name].groups
  if not node_groups or not node_groups.wooden then return end -- no node groups or none that are wood
  local tool = digger:get_wielded_item()
  if not tool or not tool:get_definition().groups.axe then return end -- no tool

  if prevent_break then
    local wear = tool:get_wear()
    local tool_capabilities = tool:get_tool_capabilities()
    local dig_params = mt.get_dig_params(node_groups, tool_capabilities, wear)
    if wear >= 65536 - dig_params.wear * 9 then return end
  end

  if digger:get_hp() == 0 then return end -- he dead
  local d = delay
  if not mt.check_player_privs(digger, "lumberjack") then d = d * 100 end
  mt.after(d, function()
    local next_pos = mt.find_node_near(pos, max_radius, oldnode.name)
    if not next_pos then return end
    if only_upward and next_pos.y < pos.y then return end
    local digger_pos = digger:get_pos()
    if not digger_pos then return end
    if pos:distance(digger_pos) > max_distance then return end
    mt.node_dig(next_pos, mt.get_node(next_pos), digger)
    chop_recursive(pos, oldnode, digger)
  end)
end

mt.register_privilege("lumberjack", privilege)
mt.register_on_dignode(chop_recursive)
