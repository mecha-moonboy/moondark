-- speed berry
local quick_effect = {
    name = "md_consumables:brawsterry_effect",
    factor = 2, -- multiply player speed by this
    duration = 10,
    on_use = md_effects.give_quick_effect,
}

md_effects.register_consumable("md_consumables:brawsterry", quick_effect, {
    description = "brawsterry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#aa1111ff",
})

-- zero gravity berry
local quick_effect = {
    name = "md_consumables:zorberry_effect",
    factor = -0.025, -- multiply player gravity by this
    --is_dur = true,
    duration = 2,
    on_use = md_effects.give_weightless_effect,
}

md_effects.register_consumable("md_consumables:zorberry", quick_effect, {
    description = "zorberry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#110011ff",
})

-- vloo berry
local quick_effect = {
    name = "md_consumables:vlooberry_effect",
    factor = 1, -- how many seconds between add a heart
    duration = 5,
    on_use = md_effects.give_restoration_effect,
}

md_effects.register_consumable("md_consumables:vlooberry", quick_effect, {
    description = "vlooberry",
    inventory_image = "berries.png",
    groups = {food = 1},
    color = "#117711ff",
})