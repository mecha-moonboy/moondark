local mn = "moondark"
local gr = {
    _x = "",
    srg = "group:string",
    stk = "group:stick",
    sne = "group:stone",
}
minetest.register_craft({ output = "moondark:cord",
    recipe = {
        {"group:fiber", "group:fiber"},
        {"group:fiber", "group:fiber"}
    }
})

minetest.register_craft({ output = "moondark:rake",
    recipe = {
        {gr.stk, gr.stk, gr.stk},
        {gr.srg, gr.stk, gr.srg},
        {"", gr.stk, ""}
    }
})

minetest.register_craft({ output = "moondark:digging_stick",
    recipe = {
        {""    , gr.stk, gr.stk},
        {gr.srg, gr.stk, gr.srg},
        {gr.stk, ""    , ""    }
    }
})

minetest.register_craft({ output = "moondark:axe_stone",
    recipe = {
        {gr.sne, gr.sne},
        {gr.sne, gr.stk},
        {gr.srg, gr.stk}
    }
})

minetest.register_craft({ output = "moondark:sword_stone",
    recipe = {
        {"", "group:stone"},
        {"group:string", "group:stone"},
        {"", "group:stick"}
    }
})

minetest.register_craft({ output = "moondark:pick_stone",
    recipe = {
        {"group:stone", "group:stone", "group:stone"},
        {"group:string", "group:stick", "group:string"},
        {"", "group:stick", ""}
    }
})