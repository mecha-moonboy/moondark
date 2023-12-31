md_effects.register_consumable("md_consumables:thrumberry", {
    description = "thrumberry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#117711ff",
    --effect_name = "md_consumables:thrumberry_effect",
    --duration = 5,
    on_use = function(itemstack, user, pointed_thing)
        md_effects.give_effect(user, "md_consumables:thrumberry_effect", 5)
    end
})

md_effects.register_consumable("md_consumables:brawsterry", {
    description = "brawsterry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#ff1111ff",
    --effect_name = "md_consumables:brawsterry_effect",
    on_use = function(itemstack, user, pointed_thing)
        md_effects.give_effect(user, "md_consumables:brawsterry_effect", 5)
    end
})