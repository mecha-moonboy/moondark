local E=...
local W,H,SCALING=E.W,E.H,E.SCALING
local DEBUG_CG=false
local display_recipe=E.display_recipe
local esc = minetest.formspec_escape

local player_data={}
local glodata

local function itemlist_form(data)
	local form = 
		"image_button[5,4;0.8,0.8;craftguide_prev_icon.png;glcraft_gitems_prev;]" ..
		"image_button[7.2,4;0.8,0.8;craftguide_next_icon.png;glcraft_gitems_next;]" ..
		"field[0.3,4.3;3,0.8;glcraft_gitems_filter;;"..esc(data.filter or "").."]" ..
		"field_close_on_enter[glcraft_gitems_filter;false]"..
		"image_button[2.8,4;0.8,0.8;craftguide_search_icon.png;glcraft_gitems_search;]" ..
		("label[5.8,4.15;%s / %s]"):format(esc(minetest.colorize("yellow",data.page)),data.npages)
	local off=(data.page-1)*(W*H)+1
	for x=0,W-1 do
		for y=0,H-1 do
			local off=off+x+y*W
			local item = data.items[off]
			if item then
				form = form .. E.item_button{
					x=x*SCALING,y=y*SCALING,
					scaling=SCALING,
					item = item,
					name="glcraft_gitems_item_"..minetest.encode_base64(item) --item
				}
			end
		end
	end
	return form
end

local function craftlist_form(data)
	local modes={}
	modes.recipes="Recipe"
	modes.usages="Usage"
	local form = 
		("image_button[4,8.5;0.8,0.8;craftguide_prev_icon.png;glcraft_gcrafts_prev;]" ..
		"image_button[7.2,8.5;0.8,0.8;craftguide_next_icon.png;glcraft_gcrafts_next;]" ..
		("label[4.8,8.55;%s %s / %s]"):format(modes[data.mode],esc(minetest.colorize("yellow",(data.recipe and #data.recipes>0) and data.n or "?")),#data.recipes))
	if data.recipe then
		form=form.."container[0,5]"
		form=form..display_recipe(
			data.recipe,data.count,
			"glcraft_gitems_item_",nil,
			glodata.imap,data.mode=="usages" and data.item or nil,
			E.rand_fn(data.rands))
		form=form.."container_end[]"
	end
	return form
end

local function get_formspec(player)
	local name = player:get_player_name()
	local data = player_data[name]
	local form=itemlist_form(data.items)
	if data.crafts then
		form=form..craftlist_form(data.crafts)
	end
	return form
end

local function dgd(fu)
	return function(...)
		if glodata then
			glodata.dirty=true
		end
		for k,v in pairs(player_data) do
			v.gld_dirty=true
		end
		return fu(...)
	end
end
E.scan_recipes=dgd(E.scan_recipes)
E.scan_usages=dgd(E.scan_usages)
E.scan_groups=dgd(E.scan_groups)

local function update_glodata()
	local re=E.scan_recipes_now() or E.scan_groups_now()
	if re or (not glodata) or glodata.dirty then
		local items={}
		local Erecipes,Eusages={},{}
		for ou,v in pairs(E.recipes) do
			for reci,v in pairs(v) do
				local recip=reci.recipe or reci.inputs or {}
				if type(recip)=="string" then
					recip={recip}
				end
				if type(recip[1])=="table" then
					local rr=recip
					recip={}
					for k,v in pairs(rr) do
						for k,v in pairs(v) do
							recip[#recip+1]=v
						end
					end
				end
				if not E.cg_blacklisted_recipes[reci] and not E.table_eq({ou},recip) then
					Erecipes[ou]=Erecipes[ou] or {}
					Erecipes[ou][reci]=v
				end
			end
		end
		for ou,v in pairs(E.usages) do
			for reci,v in pairs(v) do
				if not E.cg_blacklisted_recipes[reci] then
					Eusages[ou]=Eusages[ou] or {}
					Eusages[ou][reci]=v
				end
			end
		end
		local imap={}
		local citems={}
		for k,v in pairs(minetest.registered_items) do
			local groups=v.groups or {}
			local nici=groups.not_in_creative_inventory
			local nicg=groups.not_in_craft_guide
			nici = nici and nici~=0
			nicg = nicg and nicg~=0
			if k~="" and
			   (Erecipes[k] or E.recipes_custom[k] or Eusages[k])
			   and not nici
			   and not nicg
			   and not E.cg_blacklisted_items[k] then
				table.insert(items,k)
				imap[k]=true
			end
			if k~="" and 
			   (Erecipes[k] or E.recipes_custom[k] or Eusages[k]) then
				table.insert(citems,k)
			end
		end
		table.sort(items)
		local crafts={}
		local usages={}
		for _,item in pairs(citems) do
			if Erecipes[item] then
				for recipe,_ in pairs(Erecipes[item]) do
					crafts[item]=crafts[item] or {}
					table.insert(crafts[item],recipe)
				end
			end
			if E.recipes_custom[item] then
				for recipe,_ in pairs(E.recipes_custom[item]) do
					crafts[item]=crafts[item] or {}
					table.insert(crafts[item],recipe)
				end
			end
			if Eusages[item] then
				for recipe,_ in pairs(Eusages[item]) do
					usages[item]=usages[item] or {}
					table.insert(usages[item],recipe)
				end
			end
			if crafts[item] then
				E.sort_recipes(crafts[item])
			end
			if usages[item] then
				E.sort_recipes(usages[item])
			end
		end
		glodata=glodata or {}
		glodata.dirty=nil
		glodata.items=items
		glodata.crafts=crafts
		glodata.usages=usages
		glodata.imap=imap
	end
end

local function update_itemlist(player,first)
	update_glodata()
	local name=player:get_player_name()
	local pdata=player_data[name]
	local data=pdata.items or {}
	pdata.items=data
	data.items=data.items or E.apply_filter(glodata.items,data.filter)
	data.crafts=glodata.crafts
	data.usages=glodata.usages
	data.npages=math.max(1,math.ceil(#data.items/(W*H)))
	data.page=math.min(data.npages,data.page or 1)
	if pdata.gld_dirty then
		data.items=E.apply_filter(glodata.items,data.filter,pdata.info.lang_code)
		data.npages=math.max(1,math.ceil(#data.items/(W*H)))
		data.page=math.min(data.npages,data.page or 1)
		pdata.gld_dirty=false
		if sfinv.get_or_create_context(player).page==E.guide_page then
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
		if fields.glcraft_gitems_prev then
			p=p-1
		end
		if fields.glcraft_gitems_next then
			p=p+1
		end
		if p~=0 then
			data.page=(data.page+p-1)%data.npages+1
			return true
		end
		if fields.glcraft_gitems_search or fields.key_enter_field=="glcraft_gitems_filter" then
			data.filter=fields.glcraft_gitems_filter
			data.items=E.apply_filter(glodata.items,data.filter,pdata.info.lang_code)
			data.npages=math.max(1,math.ceil(#data.items/(W*H)))
			data.page=math.min(data.npages,data.page or 1)
			return true
		end
		local ilb_pre="glcraft_gitems_item_"
		for k,v in pairs(fields) do
			if k:sub(1,#ilb_pre)==ilb_pre then
				local it=k:sub(#ilb_pre+1,-1)
				it=minetest.decode_base64(it)
				if it then
					if it:sub(1,6)=="group:" then
						data.filter=ItemStack(it):get_name()
						data.items=E.apply_filter(glodata.items,data.filter,pdata.info.lang_code)
					data.npages=math.max(1,math.ceil(#data.items/(W*H)))
					data.page=math.min(data.npages,data.page or 1)
						return true
					else
						local it=ItemStack(it):get_name()
						local recips
						local mode="recipes"
						if pdata.crafts and pdata.crafts.mode=="recipes" and pdata.crafts.item==it then
							recips=data.usages[it]
							mode="usages"
						else
							recips=data.crafts[it]
						end
						recips=recips or {}
						local recip=recips[1]
						if not recip then
							if mode=="recipes" then
								recip={
									type="custom",
									recip_icon={icon="craftguide_clear_icon.png",tooltip="No recipes"},
									inputs={{""}},
									outputs={{it}}
								}
							else
								recip={
									type="custom",
									recip_icon={icon="craftguide_clear_icon.png",tooltip="No usages"},
									inputs={{it}},
									outputs={{""}}
								}
							end
						end
						pdata.crafts={n=1,recipe=recip,item=it,mode=mode,recipes=recips,
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
			if fields.glcraft_gcrafts_prev then
				p=p-1
			end
			if fields.glcraft_gcrafts_next then
				p=p+1
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
        local name = player:get_player_name()
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
		return sfinv.make_formspec(player, context, get_formspec(player))
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
		sfinv.register_page("glcraft:craftguide",{
			title="Recipes",
			get=get,
			on_player_receive_fields=on_player_receive_fields
		})
	else
		sfinv.override_page("mtg_craftguide:craftguide", {
			get=get,
			on_player_receive_fields=on_player_receive_fields
		})
	end
end
