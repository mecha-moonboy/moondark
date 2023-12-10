minetest.register_craftitem("moondark:straw", {
    description = "straw",
    inventory_image = "straw.png",
    groups = {fiber = 1, flammable = 1},
    color = "#c09010ff",
})

minetest.register_craftitem("moondark:cord", {
    description = "cord",
    inventory_image = "string.png",
    groups = {string = 2, flammable = 1},
    color = "#c09010ff",
})

minetest.register_craftitem("moondark:stick", {
    description = "stick",
    inventory_image = "stick.png",
    groups = {stick = 1, flammable = 1},
    color = "#603010ff"
})

minetest.register_craftitem("moondark:clay_blob", {
    description = "clay blob",
    inventory_image = "blob.png",
    color = "#777777ff"
})