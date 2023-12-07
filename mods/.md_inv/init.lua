dofile(minetest.get_modpath("md_inv") .. "/api.lua")

-- Load support for MT game translation.
local S = minetest.get_translator("md_inv")

md_inv.register_page("md_inv:crafting", {
	title = S("Crafting"),
	get = function(self, player, context)
		return md_inv.make_formspec(player, context, [[
				list[current_player;craft;1.75,0.5;3,3;]
				list[current_player;craftpreview;5.75,1.5;1,1;]
				image[4.75,1.5;1,1;sfinv_crafting_arrow.png]
				listring[current_player;main]
				listring[current_player;craft]
			]], true)
	end
})