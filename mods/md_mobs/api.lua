md_mobs.registered_mobs = {}
md_mobs.hostiles = {}
md_mobs.natural = {}

function md_mobs.register_mob(name, definition)
    md_mobs.registered_mobs[name] = definition
    md_mobs.register_mob_seal(name)

    minetest.register_entity("md_mobs:"..name, definition.entity)
end

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
                md_mobs.spawn_mob("md_mobs:"..mobname, pointed_thing.above)
            end
        end,
    })
end

-- spawn a registered mob at a given location
function md_mobs.spawn_mob(name, pos)
    -- Mix up scale?
    -- Random color?

    minetest.add_entity(pos, name)
end

-- The next 3 functions should be called after a timer in globalstep
-- spawn nature mobs
function md_mobs.do_natural_spawn_step()

end

-- remove excess and any otherwise useless mobs (and other entities?)
function md_mobs.do_despawn_step()

end

-- remove a mob from the world according to it's entity instance
function md_mobs.delete_mob(entity_instance)

end

-- check if a registered mob can fit their hitbox within a location (zeroed on the ground Y level)
function md_mobs.can_spawn(mobname, pos)

end