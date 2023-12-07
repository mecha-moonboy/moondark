md_inv = {
    pages = {},
    pages_unordered = {},
    contexts = {},
    enabled = true,
}

function md_inv.register_page(name, def)
	assert(name, "Invalid inventory page. Requires a name")
	assert(def, "Invalid inventory page. Requires a def[inition] table")
	assert(def.get, "Invalid inventory page. Def requires a get function.")
	assert(not md_inv.pages[name], "Attempt to register already registered inventory page " .. dump(name))

	md_inv.pages[name] = def
	def.name = name
	table.insert(md_inv.pages_unordered, def)
end

function md_inv.get_nav_fs(player, context, nav, current_idx)
	-- Only show tabs if there is more than one page
	if #nav > 1 then
		return "tabheader[0,0;sfinv_nav_tabs;" .. table.concat(nav, ",") ..
				";" .. current_idx .. ";true;false]"
	else
		return ""
	end
end

local theme_inv = [[
		image[0,5.2;1,1;gui_hb_bg.png]
		image[1,5.2;1,1;gui_hb_bg.png]
		image[2,5.2;1,1;gui_hb_bg.png]
		image[3,5.2;1,1;gui_hb_bg.png]
		image[4,5.2;1,1;gui_hb_bg.png]
		image[5,5.2;1,1;gui_hb_bg.png]
		image[6,5.2;1,1;gui_hb_bg.png]
		image[7,5.2;1,1;gui_hb_bg.png]
		list[current_player;main;0,5.2;8,1;]
		list[current_player;main;0,6.35;8,3;8]
	]] -- edited last line

function md_inv.make_formspec(player, context, content, show_inv, size)
	local tmp = {
		size or "size[9,9.1]", -- edited size from 8, 9.1
		md_inv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
		show_inv and theme_inv or "",
		content
	}
	return table.concat(tmp, "")
end