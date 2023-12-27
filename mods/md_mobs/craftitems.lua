-- Register a new mob seal. Mob must already be registered.
function md_mobs.register_mob_seal(mobname)
    -- Get the definition of the registered mob.
    local mob = md_mobs.registered_mobs[mobname]
    -- Register spawn item for a mob.
    minetest.register_craftitem("md_mobs:seal_"..mobname, {
        description = "seal of the " .. mob.description, -- Maybe get mob's registered description for this?
        inventory_image = "seal_comp_".. mob.seal_comp_1 .. ".png^seal_comp_"..mob.seal_comp_2 .. ".png",
        on_use = function(itemstack, user, pointed_thing)
            if pointed_thing and pointed_thing.type == "node" then
                -- Call spawn function.
                md_mobs.spawn_mob(mobname, pointed_thing.above)
            end
        end,
    })
end