md_effects.register_effect("md_consumables:thrumberry_effect", {
    name = "md_consumables:thrumberry_effect",
    meta_tag = "_thrumberry",
    particle_color = "#447711ff",
    particle_texture = "plus.png",
    factor = 1, -- how many seconds between adding a heart
    step = 1, -- how many seconds between calling 'on_step'
    on_step = function(entity)
        entity:set_hp(math.min(entity:get_properties().hp_max or 20, entity:get_hp() + 1), {type = "set_hp", other = "restoration"})
    end
})

-- straw berry
md_effects.register_effect("md_consumables:brawsterry_effect", {
    name = "md_consumables:brawsterry_effect",
    meta_tag = "_brawsterry",
    particle_color = "#aa2211ff",
    particle_texture = "plus.png",
    physics_override = {attribute = "speed", id = "md_consumables:brawsterry_effect", factor = 2}
})