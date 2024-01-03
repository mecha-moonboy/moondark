md_fire.register_flammable_item("moondark:lowan_log", {
    flammable = 2,
    burn_chance = 12,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:lowan_wood", {
    flammable = 2,
    burn_chance = 10,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:lowan_leaves", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "md_fire:ash"
})

md_fire.register_flammable_item("moondark:sprute_log", {
    flammable = 2,
    burn_chance = 8,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:sprute_wood", {
    flammable = 2,
    burn_chance = 6,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:sprute_needles", {
    flammable = 2,
    burn_chance = 1,
    after_burned = "md_fire:ash"
})

md_fire.register_flammable_item("moondark:malpa_log", {
    flammable = 2,
    burn_chance = 10,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:malpa_wood", {
    flammable = 2,
    burn_chance = 6,
    after_burned = "md_fire:ember"
})
md_fire.register_flammable_item("moondark:malpa_leaves", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "md_fire:ash"
})

md_fire.register_flammable_item("moondark:stick", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "air"
})
md_fire.register_flammable_item("moondark:grass", {
    flammable = 1,
    burn_chance = 1,
    after_burned = "air"
})
md_fire.register_flammable_item("moondark:driftwood", {
    flammable = 2,
    burn_chance = 2,
    after_burned = "md_fire:ash"
})
-- md_fire.register_flammable_item("md_fire:charcoal", {
--     flammable = 2,
--     burn_chance = 30,
--     after_burned = "md_fire:"
-- })

md_fire.register_breathable_node("moondark:grass", 1)
md_fire.register_breathable_node("md_fire:fire_1", 1)
md_fire.register_breathable_node("md_fire:fire_2", 1)
md_fire.register_breathable_node("md_fire:ash", 1)


-- md_fire.register_breathable_node("group:leaves", 1)

minetest.override_item("air", {groups = {breathable = 1}})