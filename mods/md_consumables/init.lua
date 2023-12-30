-- -- speed berry
-- local quick_effect = {
--     name = "md_consumables:brawsterry_effect",
--     factor = 2, -- multiply player speed by this
--     duration = 10,
--     particle_color = "#aa1111ff",
--     on_use = function(player, fac, dur)
--         md_effects.give_effect(player, fac, dur, md_effects.active_effects.quick, function()
--             md_physics.add_physics_factor(player, "speed", "md_effects:quick", fac)
--         end)
--     end,
--     physics_override = {factor = 2, attribute = "speed", id = "md_consumable:quick"}
-- }

-- md_effects.register_consumable("md_consumables:brawsterry", quick_effect, {
--     description = "brawsterry",
--     inventory_image = "berries.png",
--     groups = {food = 1},
--     color = "#aa1111ff",
-- })

-- -- zero gravity berry
-- local zero_grav_effect = {
--     name = "md_consumables:zorberry_effect",
--     factor = -0.025, -- multiply player gravity by this
--     --is_dur = true,
--     duration = 2,
--     on_use = function(player, fac, dur)
--         md_effects.give_effect(player, fac, dur, md_effects.active_effects.weightless, function()
--             md_physics.add_physics_factor(player, "gravity", "md_effects:weightless", fac)
--         end)
--     end
-- }

-- md_effects.register_consumable("md_consumables:zorberry",
--     zero_grav_effect,
--     {
--         description = "zorberry",
--         inventory_image = "berries.png",
--         groups = {food = 1},
--         color = "#110011ff",
--     })

-- thrum berry
md_effects.register_effect("md_consumables:thrumberry_effect", {
    name = "md_consumables:thrumberry_effect",
    meta_tag = "_thrumberry",
    particle_color = "#447711ff",
    particle_texture = "plus.png",
    factor = 1, -- how many seconds between add a heart
    step = 1, -- how many seconds between calling 'on_step'
    on_step = function(entity)
        entity:set_hp(math.min(entity:get_properties().hp_max or 20, entity:get_hp() + 1), {type = "set_hp", other = "restoration"})
    end
})

md_effects.register_consumable("md_consumables:thrumberry", {
    description = "thrumberry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#117711ff",
    effect_name = "md_consumables:thrumberry_effect",
    --duration = 5,
    on_use = function(itemstack, user, pointed_thing)
        md_effects.give_effect(user, "md_consumables:thrumberry_effect", 5)
    end
})

-- straw berry
md_effects.register_effect("md_consumables:brawsterry_effect", {
    name = "md_consumables:brawsterry_effect",
    meta_tag = "_brawsterry",
    particle_color = "#aa2211ff",
    particle_texture = "plus.png",
    --factor = 2, -- how many seconds between add a heart
    --step = 1, -- how many seconds between calling 'on_step'
    start_func = function(player)
        md_physics.add_physics_factor(player, "speed", "md_consumables:brawsterry_effect", 2)
    end
})

md_effects.register_consumable("md_consumables:brawsterry", {
    description = "brawsterry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#ff1111ff",
    effect_name = "md_consumables:thrumberry_effect",
    on_use = function(itemstack, user, pointed_thing)
        if not minetest.is_player(user) then
            return
        end
        md_effects.give_effect(user, "md_consumables:brawsterry_effect", 5)
    end
})