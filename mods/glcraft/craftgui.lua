local shlocals=...
local E=shlocals
local W,H,SCALING=shlocals.W,shlocals.H,shlocals.SCALING
local DEBUG_CG=false
local display_recipe=shlocals.display_recipe
local esc = minetest.formspec_escape

local player_data={}

local function itemlist_form(data)
	local form = 
		"image_button[5,4;0.8,0.8;craftguide_prev_icon.png;glcraft_items_prev;]" ..
		"image_button[7.2,4;0.8,0.8;craftguide_next_icon.png;glcraft_items_next;]" ..
		"field[0.3,4.3;3,0.8;glcraft_items_filter;;"..esc(data.filter or "").."]" ..
		"field_close_on_enter[glcraft_items_filter;false]"..
		"image_button[2.8,4;0.8,0.8;craftguide_search_icon.png;glcraft_items_search;]" ..
		("label[5.8,4.15;%s / %s]"):format(esc(minetest.colorize("yellow",data.page)),data.npages)
	local off=(data.page-1)*(W*H)+1
	for x=0,W-1 do
		for y=0,H-1 do
			local off=off+x+y*W
			local item = data.items[off]
			if item then
				form = form .. shlocals.item_button{
					x=x*SCALING,y=y*SCALING,
					scaling=SCALING,
					item = item,
					name="glcraft_items_item_"..minetest.encode_base64(item) --item
				}
			end
		end
	end
	return form
end

local function craftlist_form(data)
	local form = 
		(data.count and "button[5,4;3,0.8;glcraft_crafts_craft;Craft]" or
		("image_button[5,4;0.8,0.8;craftguide_prev_icon.png;glcraft_crafts_prev;]" ..
		"image_button[7.2,4;0.8,0.8;craftguide_next_icon.png;glcraft_crafts_next;]" ..
		("label[5.8,4.15;%s / %s]"):format(esc(minetest.colorize("yellow",data.n or "?")),#data.recipes)))..
		("button[0,4;0.8,0.8;glcraft_crafts_back;%s]"):format(data.count and esc("X") or esc("<-"))
		
	if data.n then
		for k,v in ipairs{"1","10","100"} do
			form=form..("button[%s,4;0.9,0.8;glcraft_crafts_craft_%s;+%s]"):format((k-1)*0.7+0.7,v,v)
		end
	end
	if data.count then
		form=form..("label[3,4.15;%s]"):format(data.count)
	end
	if data.recipe then
		form=form.."container[0,0.5]"
		form=form..display_recipe(data.recipe,data.count,nil,true,data.imap,nil,E.rand_fn(data.rands))
		form=form.."container_end[]"
	end
	return form
	
end

local function get_formspec(player)
	local name = player:get_player_name()
	local data = player_data[name]
	if data.crafts then
		return craftlist_form(data.crafts)
	end
	return itemlist_form(data.items)
end

local function update_itemlist(player,first)
	local name=player:get_player_name()
	local items={}
	local pdata=player_data[name]
	local data=pdata.items or {}
	player_data[name].items=data
	local oldinv=data.oldinv
	local inv=player:get_inventory()
	do
		local cli=inv:get_list("craft")
		local clpos=player:get_pos()
		for k,v in ipairs(cli) do
			if v:to_string()~="" then
				minetest.handle_node_drops(clpos,{v:to_string()},player)
				v:set_count(0)
			end
		end
		inv:set_list("craft",cli)
	end
	local invl=dump(inv:get_list("main"))
	if invl~=data.oldinv then
		data.oldinv=invl
		local crafts=glcraft.get_craftables(inv)
		local imap={}
		for k,v in ipairs(inv:get_list("main")) do
			local v=v:get_name()
			if v~="" then
				imap[v]=true
			end
		end
		data.imap=imap
		data.crafts=crafts
		for k,v in pairs(crafts) do
			table.insert(items,k)
		end
		if pdata.crafts then
			local data=pdata.crafts
			data.imap=pdata.items.imap
			data.recipes=crafts[data.item] or {}
			if data.recipes[data.n]~=data.recipe then
				data.n=nil
			end
			if not data.n then
				for k,v in pairs(data.recipes) do
					if v==data.recipe then
						data.n=k
					end
				end
			end
		end
		table.sort(items)
		data._items=items
		data.items=E.apply_filter(data._items,data.filter,pdata.info.lang_code)
		data.npages=math.max(1,math.ceil(#items/(W*H)))
		data.page=math.min(data.npages,data.page or 1)
		if not first and sfinv.get_or_create_context(player).page==E.craftgui_page then
			sfinv.set_player_inventory_formspec(player)
		end
	end
end

local function on_receive_fields(player,fields)
	local name=player:get_player_name()
	local data=player_data[name]
	do -- Items list
		local pdata=data
		local data=data.items
		local p=0
		if fields.glcraft_items_prev then
			p=p-1
		end
		if fields.glcraft_items_next then
			p=p+1
		end
		if p~=0 then
			data.page=(data.page+p-1)%data.npages+1
			return true
		end
		if fields.glcraft_items_search or fields.key_enter_field=="glcraft_items_filter" then
			data.filter=fields.glcraft_items_filter
			data.items=E.apply_filter(data._items,data.filter,pdata.info.lang_code)
			data.npages=math.max(1,math.ceil(#data.items/(W*H)))
			data.page=math.min(data.npages,data.page or 1)
			return true
		end
		local ilb_pre="glcraft_items_item_"
		for k,v in pairs(fields) do
			if k:sub(1,#ilb_pre)==ilb_pre then
				local it=k:sub(#ilb_pre+1,-1)
				it=minetest.decode_base64(it)
				if it then
					local recipes=data.crafts[it]
					if recipes then
						pdata.crafts={n=1,recipe=recipes[1],item=it,recipes=recipes,imap=data.imap,
						rands=math.random(2^31-1)}
						return true
					end
				end
			end
		end
	end
	do -- Craft list 
		local pdata=data
		local data=data.crafts
		if data then
			local p=0
			if fields.glcraft_crafts_prev then
				p=p-1
			end
			if fields.glcraft_crafts_next then
				p=p+1
			end
			if fields.glcraft_crafts_back then
				if data.count then
					data.count=nil
				else
					pdata.crafts=nil
				end
				data.rands=math.random(2^31-1)
				return true
			end
			if p~=0 then
				if #data.recipes>0 then
					if data.n then
						data.n=(data.n+p-1)%(#data.recipes)+1
						data.recipe=data.recipes[data.n]
					else
						data.n=1
						data.recipe=data.recipes[1]
					end
					data.rands=math.random(2^31-1)
					return true
				end
			end
			local ilb_pre="glcraft_crafts_craft_"
			for k,v in pairs(fields) do
				if k:sub(1,#ilb_pre)==ilb_pre and data.recipe then
					local num=tonumber(k:sub(#ilb_pre+1,-1)) or 1
					data.count=(data.count or 0)+num
					data.rands=math.random(2^31-1)
					return true,true
				end
			end
			if fields.glcraft_crafts_craft and data.recipe and data.count then
				local c=glcraft.craft(player:get_inventory(),"main","main",data.recipe,data.count,player)
				data.count=data.count-c
				if data.count<=0 then
					data.count=nil
				end
				update_itemlist(player)
				data.rands=math.random(2^31-1)
				return true
			end
		end
	end
end

local function make_data(player)
	local name = player:get_player_name()
	if player_data[name] then return end
	player_data[name] = {}
	player_data[name].info=minetest.get_player_information(name)
	update_itemlist(player,true)
end

local function delete_data(player)
	local name = player:get_player_name()
	if not player_data[name] then return end
        player_data[name] = nil
end

minetest.register_on_joinplayer(make_data)
minetest.register_on_leaveplayer(delete_data)
minetest.register_globalstep(function(dt)
	for k,v in pairs(minetest.get_connected_players()) do
		update_itemlist(v)
	end
end)

do
	local get = function(self, player, context)
		make_data(player)
		return sfinv.make_formspec(player, context, get_formspec(player), true)
	end
	local job
        local on_player_receive_fields = function(self, player, context, fields)
		local ok,dela=on_receive_fields(player,fields)
		if ok then
			if job then
				job:cancel()
			end
			if dela then
				job=minetest.after(0.5,sfinv.set_player_inventory_formspec,player)
			else
				sfinv.set_player_inventory_formspec(player)
			end
		end
        end
	
	if DEBUG_CG then
		E.craftgui_page="glcraft:crafting"
		sfinv.register_page(E.craftgui_page,{
			title="Autocraft",
			get=get,
			on_player_receive_fields=on_player_receive_fields
		})
	else
		E.craftgui_page="sfinv:crafting"
		sfinv.override_page(E.craftgui_page, {
			get=get,
			on_player_receive_fields=on_player_receive_fields
		})
	end
end
