md_effects.register_consumable("md_herbs:thrumberry", {
    description = "thrumberry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#330066ff",
    effect_name = "md_herbs:thrumberry_effect",
    on_consume = function(user)
        md_effects.give_effect(user, "md_herbs:thrumberry_effect", 5)
    end
})

md_effects.register_consumable("md_herbs:brawsterry", {
    description = "brawsterry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#ff1111ff",
    effect_name = "md_herbs:brawsterry_effect",
    on_consume = function(user)
        md_effects.give_effect(user, "md_herbs:brawsterry_effect", 5)
    end
})