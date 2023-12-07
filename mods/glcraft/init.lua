glcraft={}
local E={}

E.W,E.H=8,4
E.SCALING=1
E.W,E.H=math.floor(E.W/E.SCALING),math.floor(E.H/E.SCALING)
E.modname=minetest.get_current_modname()
E.modpath=minetest.get_modpath(E.modname)

function E.include(path,...)
	local path=path
	if path:sub(1,1)~="/" then
		path=E.modpath.."/"..path
	end
	local ok,err=loadfile(path)
	assert(ok,err)
	return ok(...)
end

function E.table_eq(a,b)
	for k,v in pairs(a) do
		local bb=b[k]
		if not bb then return false end
		if type(v)=="table" and type(bb)=="table" then
			if not E.table_eq(v,bb) then return false end
		else
			if v~=bb then return false end
		end
	end
	for k,v in pairs(b) do
		if not a[k] then return false end
	end
	return true
end

function E.wrap_tfun(t,fn)
	return function(...)
		return t[fn](...)
	end
end

function E.plan_f(fu)
	local planned=false
	local plan
	plan=function(f)
		if f then
			return function(...)
				plan()
				return f(...)
			end
		end
		if planned then return end
		planned=true
		minetest.after(0,function()
			if planned then
				fu()
				planned=false
			end
		end)
	end
	local now=function(ig)
		if planned or ig then
			fu()
			planned=false
			return true
		end
	end
	return plan,now
end

local esc = minetest.formspec_escape

function E.rand_fn(...)
	local pcg=PcgRandom(...)
	return function(mi,ma)
		if mi then
			if mi and not ma then
				mi,ma=1,mi
			end
			return pcg:next(mi,ma)
		end
		return (pcg:next()+(2^31))/(2^32-1)
	end
end

function E.item_button(data)
	local item=data.item
	local is_gr,tooltip
	local it=ItemStack(item)
	local iname=it:get_name()
	local gggg="group:"
	if iname:sub(1,#gggg)==gggg then
		is_gr=true
		local group=iname:sub(#gggg+1,-1)
		E.scan_groups_now()
		local ggrs=E.parse_groups(iname)
		local items=E.find_of_groups(data.items or minetest.registered_items,ggrs)
		local its={}
		for k,v in pairs(items) do
			table.insert(its,k)
		end
		if #its==0 and data.items then
			items=E.find_of_groups(minetest.registered_items,ggrs)
			for k,v in pairs(items) do
				table.insert(its,k)
			end
		end
		tooltip = "Any group:"..group
		if its and #its>0 then
			it:set_name(its[(data.rand or math.random)(1,#its)])
		else
			it:set_name("unknown")
		end
	else
		local desc = ItemStack(item):get_description()
		tooltip = desc.."\n"..minetest.colorize("grey",iname)
	end
	item=it:to_string()

	local scaling = data.scaling or 1
	return ("item_image_button[%s,%s;%s,%s;%s;%s;%s]")
	       :format(data.x,data.y,(1*scaling)+0.05,(1*scaling)+0.05,esc(item),esc(data.name),is_gr and "G" or "")..
	       (tooltip and ("tooltip[%s;%s]"):format(esc(data.name),esc(tooltip)) or "")
end

local function display_cg(grid,count,prefix,leftha,imap,rand)
	local form=""
	local hei=#grid
	local wid=#grid[1]
	local offy=-(math.floor(hei/2))
	local offx=-(math.floor(leftha and (wid-1) or 0))
	for y,v in ipairs(grid) do
		for x,v in ipairs(v) do
			if v~="" then
				local x,y=(leftha and (2+offx)+(x-1) or (4+offx)+(x-1)),(1+offy)+(y-1)
				if type(v)=="string" then
					local v=ItemStack(v)
					v:set_count(v:get_count()*count)
					v=v:to_string()
					form=form..E.item_button{
						x=x,y=y,
						item=v,
						items=imap,
						rand=rand,
						name=(prefix or "glcraft_unusedib_")..minetest.encode_base64(v),
					}
				elseif type(v)=="function" then
					form=form..v(x,y)
				end
			end
		end
	end
	return form
end

function E.display_recipe_raw(recipe,count,prefix,imap,rand)
	local form="image[3,1;1,1;sfinv_crafting_arrow.png]"
	if recipe.recip_icon then
		form=form..
		"image[3.15,0.15;0.75,0.75;"..recipe.recip_icon.icon.."]"..
		"tooltip[3,0;0.8,0.8;"..recipe.recip_icon.tooltip.."]"
	end
	form=form..display_cg(recipe.inputs,count,prefix,true,imap,rand)
	form=form..display_cg(recipe.outputs,count,prefix,false,imap,rand)
	return form
end

function E.apply_filter(items,filter,lang)
	if not filter or filter=="" then return items end
	local lang=lang or "en"
	local fitems = {}
	local groups=E.parse_groups(filter)
	if groups then
		local iitems={}
		for k,v in ipairs(items) do
			iitems[v]=true
		end
		its=E.find_of_groups(iitems,groups)
		for _,name in ipairs(items) do
			local def=minetest.registered_items[name]
			if its[name] then
				table.insert(fitems,name)
			end
		end
	else
		for _,name in ipairs(items) do
			local def=minetest.registered_items[name]
			local desc=def.description or def.short_description
			if desc then
				desc=minetest.get_translated_string(lang,desc)
			end
			local matches=false
			for k,v in ipairs{name,desc} do
				local v,filter=v:lower(),filter:lower()
				if v:find(filter) then
					matches=true
				end
			end
			if matches then
				table.insert(fitems,name)
			end
		end
	end
	return fitems
end

E.include("crafting.lua",E)
E.include("m_rebl_cks.lua",E)
E.include("technic.lua",E)
E.include("craftgui.lua",E)
E.include("guide.lua",E)
