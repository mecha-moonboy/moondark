sfinv = {
	pages = {},
	pages_unordered = {},
	contexts = {},
	enabled = true
}

function sfinv.register_page(name, def)
	assert(name, "Invalid sfinv page. Requires a name")
	assert(def, "Invalid sfinv page. Requires a def[inition] table")
	assert(def.get, "Invalid sfinv page. Def requires a get function.")
	assert(not sfinv.pages[name], "Attempt to register already registered sfinv page " .. dump(name))

	sfinv.pages[name] = def
	def.name = name
	table.insert(sfinv.pages_unordered, def)
end

function sfinv.override_page(name, def)
	assert(name, "Invalid sfinv page override. Requires a name")
	assert(def, "Invalid sfinv page override. Requires a def[inition] table")
	local page = sfinv.pages[name]
	assert(page, "Attempt to override sfinv page " .. dump(name) .. " which does not exist.")
	for key, value in pairs(def) do
		page[key] = value
	end
end

function sfinv.get_nav_fs(player, context, nav, current_idx)
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

function sfinv.make_formspec(player, context, content, show_inv, size)
	local tmp = {
		size or "size[9,9.1]", -- edited size from 8, 9.1
		sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
		show_inv and theme_inv or "",
		content
	}
	return table.concat(tmp, "")
end

function sfinv.get_homepage_name(player)
	return "sfinv:crafting"
end

function sfinv.get_formspec(player, context)
	-- Generate navigation tabs
	local nav = {}
	local nav_ids = {}
	local current_idx = 1
	for i, pdef in pairs(sfinv.pages_unordered) do
		if not pdef.is_in_nav or pdef:is_in_nav(player, context) then
			nav[#nav + 1] = pdef.title
			nav_ids[#nav_ids + 1] = pdef.name
			if pdef.name == context.page then
				current_idx = #nav_ids
			end
		end
	end
	context.nav = nav_ids
	context.nav_titles = nav
	context.nav_idx = current_idx

	-- Generate formspec
	local page = sfinv.pages[context.page] or sfinv.pages["404"]
	if page then
		return page:get(player, context)
	else
		local old_page = context.page
		local home_page = sfinv.get_homepage_name(player)

		if old_page == home_page then
			minetest.log("error", "[sfinv] Couldn't find " .. dump(old_page) ..
					", which is also the old page")

			return ""
		end

		context.page = home_page
		assert(sfinv.pages[context.page], "[sfinv] Invalid homepage")
		minetest.log("warning", "[sfinv] Couldn't find " .. dump(old_page) ..
				" so switching to homepage")

		return sfinv.get_formspec(player, context)
	end
end

function sfinv.get_or_create_context(player)
	local name = player:get_player_name()
	local context = sfinv.contexts[name]
	if not context then
		context = {
			page = sfinv.get_homepage_name(player)
		}
		sfinv.contexts[name] = context
	end
	return context
end

function sfinv.set_context(player, context)
	sfinv.contexts[player:get_player_name()] = context
end

function sfinv.set_player_inventory_formspec(player, context)
	local fs = sfinv.get_formspec(player,
			context or sfinv.get_or_create_context(player))
	player:set_inventory_formspec(fs)
end

function sfinv.set_page(player, pagename)
	local context = sfinv.get_or_create_context(player)
	local oldpage = sfinv.pages[context.page]
	if oldpage and oldpage.on_leave then
		oldpage:on_leave(player, context)
	end
	context.page = pagename
	local page = sfinv.pages[pagename]
	if page.on_enter then
		page:on_enter(player, context)
	end
	sfinv.set_player_inventory_formspec(player, context)
end

function sfinv.get_page(player)
	local context = sfinv.contexts[player:get_player_name()]
	return context and context.page or sfinv.get_homepage_name(player)
end

minetest.register_on_joinplayer(function(player)
	if sfinv.enabled then
		sfinv.set_player_inventory_formspec(player)
	end
end)

minetest.register_on_leaveplayer(function(player)
	sfinv.contexts[player:get_player_name()] = nil
end)

local is_in_list = function(list, value)
	for _, listItem in ipairs(list) do
        if listItem == value then
            return true -- Found the value in the list
        end
    end
    return false -- Value not found in the list
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	--minetest.log("log", "A key was pressed in the inventory. Serializing: " .. minetest.serialize(fields) )
	if formname ~= "" or not sfinv.enabled then
		return false
	end
	-- Get Context
	local name = player:get_player_name()
	local context = sfinv.contexts[name]
	if not context then
		sfinv.set_player_inventory_formspec(player)
		return false
	end

	-- Was a tab selected?
	if fields.sfinv_nav_tabs and context.nav then
		local tid = tonumber(fields.sfinv_nav_tabs)
		if tid and tid > 0 then
			local id = context.nav[tid]
			local page = sfinv.pages[id]
			if id and page then
				sfinv.set_page(player, id)
			end
		end
	else
		-- Pass event to page
		local page = sfinv.pages[context.page]
		if page and page.on_player_receive_fields then
			return page:on_player_receive_fields(player, context, fields)
		end
	end

end)

-- local q_drop_pages = {"sfinv:crafting", "mtg_craftguide:craftguide", "glcraft:craftguide",}
-- minetest.register_on_player_receive_fields(function(player, formname, fields)
-- 	--minetest.log("log", "A key was pressed in the inventory")
-- 	if is_in_list(q_drop_pages, formname) then
-- 		-- Check for the 'drop_item' action when the Q key is pressed
--         if fields.key == "q" then
-- 			--minetest.log("log", "Q key was pressed in the inventory")
--             -- Implement logic to drop the itemstack
--             -- Example: Get the hovered item and drop it from the player's inventory
--             local hovered_item = player:get_wielded_item()
--             if hovered_item:is_empty() then
--                 return
--             end

--             -- Drop the itemstack at the player's position
--             local player_pos = player:get_pos()
--             minetest.add_item(player_pos, hovered_item)
--         end
--     end
-- end)