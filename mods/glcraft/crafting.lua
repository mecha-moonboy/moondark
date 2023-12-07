local E = ...

E.recipes_custom={}
E.recipes={}
E.usages={}
E.cg_ctypes={shaped=true,shapeless=true}
E.item_groups={}
local table_eq=E.table_eq

function E.parse_groups(g)
	local g=ItemStack(g):get_name()
	if g:sub(1,6)=="group:" then
		local g=g:sub(7)
		local grs={}
		for gr in g:gmatch("([^,]+),?") do
			table.insert(grs,gr)
		end
		return grs
	end
end

function E.find_of_groups(items,groups)
	local gi={}
	for _,group in pairs(groups) do
		if E.item_groups[group] then
			for _,item in pairs(E.item_groups[group].list) do
				if items[item] then
					gi[item]=true
				end
			end
		end
	end
	local cl={}
	for it,_ in pairs(gi) do
		for _,group in pairs(groups) do
			if (not E.item_groups[group]) or not E.item_groups[group].map[it] then
				cl[it]=true
			end
		end
	end
	for k,v in pairs(cl) do
		gi[k]=nil
	end
	return gi
end

function E.replace_gritem(src,dst)
	local src1=ItemStack(src):get_name()
	local groups=E.parse_groups(src1)
	if not groups then return src end
	local dst1=ItemStack(dst):get_name()
	if E.find_of_groups({[dst1]=true},groups)[dst1] then
		local count=ItemStack(src):get_count()
		local dst=ItemStack(dst1)
		dst:set_count(count)
		return dst:to_string()
	end
	return src
end

local function gridify_list(grid)
	local gg,grid=grid,{}
	do
		local x,y=1,1
		for k,v in ipairs(gg) do
			grid[y]=grid[y]or{}
			grid[y][x]=v
			x=x+1
			if x>3 then
				x,y=1,y+1
			end
		end
	end
	return grid
end
E.gridify_list=gridify_list

local function shapeless_sort(grid)
	local gg=grid
	local grid={}
	for k,v in pairs(gg) do
		grid[v]=(grid[v] or 0)+1
	end
	gg,grid=grid,{}
	for k,v in pairs(gg) do
		local is=ItemStack(k)
		is:set_count(v)
		table.insert(grid,is:to_string())
	end
	table.sort(grid)
	return grid
end
E.shapeless_sort=shapeless_sort

local function shapeless_gridify(grid)
	return gridify_list(shapeless_sort(grid))
end
E.shapeless_gridify=shapeless_gridify

--function glcraft.register_recipe()
--end
--
--function glcraft.unregister_recipe()
--end

function E.scan_groups()
	E.item_groups={}
	for name,item in pairs(minetest.registered_items) do
		for group,amount in pairs(item.groups) do
			if (type(amount)=="number" and amount>0) or (type(amount)~="number" and amount) then
				E.item_groups[group] = E.item_groups[group] or {list={},map={}}
				E.item_groups[group].map[name] = true
				table.insert(E.item_groups[group].list,name)
			end
		end
	end
end

E.plan_group_scan,E.scan_groups_now=E.plan_f(E.wrap_tfun(E,"scan_groups"))
E.plan_group_scan()
for _,fname in pairs{"register_item","override_item","unregister_item"} do
	minetest[fname]=E.plan_group_scan(minetest[fname])
end

function E.resolve_alias(name)
	local ali=minetest.registered_aliases[name]
	if ali then
		return E.resolve_alias(ali)
	else
		return name
	end
end

function E.scan_recipes()
	E.scan_groups_now()
	E.recipes={}
	for item,crafts in pairs(minetest.registered_crafts) do
		for recipe,_ in pairs(crafts) do
			local item=E.resolve_alias(item)
			E.recipes[item]=E.recipes[item] or {}
			E.recipes[item][recipe]=true
		end
	end
	for k,v in pairs(minetest.registered_nodes) do
		if v.drop and minetest.get_item_group(k,"not_in_creative_inventory")==0 then
			local recip={type="custom",recip_icon={tooltip="Digging",icon="default_tool_steelpick.png"}}
			recip.inputs={{k}}
			local valid=true
			local oouts={}
			if type(v.drop)=="string" and v.drop~="" then
				recip.outputs={{v.drop}}
				oouts={ItemStack(v.drop):get_name()}
			elseif type(v.drop)=="table" and v.drop.items then
				local outs={}
				for k,v in ipairs(v.drop.items) do
					for k,v in ipairs(v.items) do
						outs[ItemStack(v):get_name()]=true
					end
				end
				local outs,oo={},outs
				for k,v in pairs(oo) do
					table.insert(outs,k)
				end
				oouts=outs
				recip.outputs=shapeless_gridify(outs)
			else
				valid=false
			end
			if valid and #oouts>0 and not table_eq(recip.inputs,recip.outputs) then
				for k,v in ipairs(oouts) do
					E.recipes[v]=E.recipes[v] or {}
					E.recipes[v][recip]=true
				end
			end
		end
	end
	E.scan_usages_now(true)
end
local function scan_ur(recipe)
	local recip=recipe.recipe or recipe.inputs or {}
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
	for k,v in pairs(recip) do
		v=ItemStack(v):get_name()
		v=E.resolve_alias(v)
		if v~="" then
			local groups=E.parse_groups(v)
			if groups then
				for _,gro in pairs(groups) do
					local gg=E.item_groups[gro]
					if gg then
						for k,v in pairs(gg.list) do
							if E.find_of_groups({[v]=true},groups)[v] then
								E.usages[v]=E.usages[v] or {}
								E.usages[v][recipe]=true
							end
						end
					end
				end
			else
				E.usages[v]=E.usages[v] or {}
				E.usages[v][recipe]=true
			end
		end
	end
end
E.scan_usages = function()
	E.scan_groups_now()
	E.usages={}
	for item,crafts in pairs(E.recipes) do
		for recipe,_ in pairs(crafts) do
			scan_ur(recipe)
		end
	end
	for item,crafts in pairs(E.recipes_custom) do
		for recipe,_ in pairs(crafts) do
			scan_ur(recipe)
		end
	end
end
E.plan_recipe_scan,E.scan_recipes_now = E.plan_f(E.wrap_tfun(E,"scan_recipes"))
E.plan_usage_scan,E.scan_usages_now = E.plan_f(E.wrap_tfun(E,"scan_usages"))
E.plan_recipe_scan()
minetest.register_craft=E.plan_recipe_scan(minetest.register_craft)
minetest.clear_craft=E.plan_recipe_scan(minetest.clear_craft)
E.scan_groups=E.plan_recipe_scan(E.scan_groups)

local function apply_replacements(rp,inp)
	for k,re in ipairs(rp) do
		if re[1]==inp then
			table.remove(rp,k)
			return re[2]
		end
	end
	return nil
end

local function get_recipe_inputs(recipe)
	local inputs={}
	local rt=recipe.type or "shaped"
	local valid=true
	local grid={replacements={},recipe={}}
	local rp={}
	for k,v in ipairs(recipe.replacements or {}) do
		rp[k]=v
	end
	if rt=="shaped" then
		for y,v in pairs(recipe.recipe) do
			grid.recipe[y]={}
			for x,v in pairs(v) do
				table.insert(inputs,v)
				grid.recipe[#inputs]=(y-1)*3+x
				grid.replacements[(y-1)*3+x]=apply_replacements(rp,v)
			end
		end
	elseif rt=="shapeless" then
		for k,v in pairs(recipe.recipe) do
			table.insert(inputs,v)
			grid.recipe[k]=#inputs
			grid.replacements[k]=apply_replacements(rp,v)
		end
	else
		valid=false
	end
	for k,v in pairs(inputs) do
		inputs[k]=E.resolve_alias(v)
	end
	return valid and inputs,grid
end

local function check_recipe_input(inp,name)
	local inp=inp
	local groups=E.parse_groups(inp)
	if groups and E.find_of_groups({[name]=true},groups)[name] then
		inp=name
	end
	return name==inp
end

function E.display_recipe(recipe,count,prefix,compress,imap,gritem,rand)
	local count=count or 1
	local grid,outputs={},{}
	local shapeless
	local rt=recipe.type or "shaped"
	local recip_icon
	if rt=="shapeless" then
		grid=recipe.recipe
		shapeless=true
		recip_icon={tooltip="Shapeless",icon="craftguide_shapeless.png"}
	elseif rt=="shaped" then
		if compress then
			for k,v in ipairs(recipe.recipe) do
				for k,v in ipairs(v) do
					if v~="" then
						table.insert(grid,v)
					end
				end
			end
			shapeless=true
		else
			grid=recipe.recipe
			shapeless=false
		end
	elseif rt=="fuel" then
		grid={{recipe.recipe}}
		local rp={}
		for k,v in ipairs(recipe.replacements or {}) do
			rp[k]=v
		end
		outputs={{function(x,y) return ("image[%s,%s;1,1;fire_basic_flame.png]tooltip[%s,%s;0.8,0.8;Fuel: %ss]"):format(x,y,x,y,recipe.burntime) end,
		apply_replacements(rp,recipe.recipe)}}
	elseif rt=="cooking" then
		grid={{recipe.recipe}}
		outputs={{recipe.output}}
		recip_icon={tooltip=recipe.cooktime and ("Cooking: %ss"):format(recipe.cooktime) or "Cooking",icon="default_furnace_front.png"}
	elseif rt=="custom" then
		grid,outputs=recipe.inputs,recipe.outputs
		assert(grid and outputs,"bad boy recipe")
		recip_icon=recipe.recip_icon
	else
		error("what is this recipe")
	end
	if shapeless then
		grid=shapeless_gridify(grid)
	end
	if E.cg_ctypes[rt] then
		local ii,grr=get_recipe_inputs(recipe)
		local its=ItemStack(recipe.output)
		local count=its:get_count()
		its:set_count(1)
		its=its:to_string()
		for n=1,count do
			table.insert(outputs,its)
		end
		local repls={}
		for k,v in pairs(grr.replacements) do
			local its=ItemStack(v)
			local count=its:get_count()
			its:set_count(1)
			its=its:to_string()
			for n=1,count do
				table.insert(repls,its)
			end
		end
		outputs=shapeless_sort(outputs)
		repls=shapeless_sort(repls)
		for k,v in ipairs(repls) do
			table.insert(outputs,v)
		end
		outputs=gridify_list(outputs)
	end
	if gritem then
		local gg=grid
		grid={}
		for y,v in pairs(gg) do
			grid[y]={}
			for x,v in pairs(v) do
				grid[y][x]=v
			end
		end
		for y,v in pairs(grid) do
			for x,i in pairs(v) do
				v[x]=E.replace_gritem(i,gritem)
			end
		end
	end
	return E.display_recipe_raw({inputs=grid,outputs=outputs,recip_icon=recip_icon},count,prefix,imap,rand)
end

function glcraft.get_craftables(inv,lname)
	local main = inv:get_list(lname or "main")
	local items={}
	local recipes={}
	for _,item in pairs(main) do
		local name=item:get_name()
		if name ~= "" then
			if not items[name] then
				if E.usages[name] then
					for k,v in pairs(E.usages[name]) do
						recipes[k]=true
					end
				end
			end
			items[name]=items[name] or 0
			items[name]=items[name]+item:get_count()
		end
	end
	local craftables={}
	for recipe,_ in pairs(recipes) do
		local inputs=get_recipe_inputs(recipe)
		if inputs then
			local items_={}
			for k,v in pairs(items) do
				items_[k]=v
			end
			local sati=true
			for _,inp in pairs(inputs) do
				if inp~="" then
					local satisfied=false
					for name,count in pairs(items_) do
						if check_recipe_input(inp,name) and items_[name]>0 then
							satisfied=true
							items_[name]=items_[name]-1
							break
						end
					end
					if not satisfied then
						sati=false
						break
					end
				end
			end
			if sati then
				local out=ItemStack(recipe.output):get_name()
				craftables[out]=craftables[out] or {}
				table.insert(craftables[out],recipe)
			end
		end
	end
	for k,v in pairs(craftables) do
		E.sort_recipes(v)
	end
	return craftables
end

function E.sort_recipes(v)
	table.sort(v,function(a,b) return (a.__reg_order or math.huge) < (b.__reg_order or math.huge) end)
end

function glcraft.craft(inv,ilname,olname,recipe,count,player,pos)
	local pos = pos or player:get_pos()
	local inputs,gg=get_recipe_inputs(recipe)
	local countz=0
	local outs={}
	if inputs then
		for n=1,count do
			local il=inv:get_list(ilname)
			local sati=true
			local cg={}
			for n=1,9 do
				cg[n]=ItemStack()
			end
			local outsr={}
			for k,inp in pairs(inputs) do
				if inp~="" then
					local satisfied=false
					for _,item in ipairs(il) do
						local name=item:get_name()
						if name~="" and check_recipe_input(inp,name) then
							cg[gg.recipe[k]]=item:take_item(1)
							satisfied=true
							break
						end
					end
					if not satisfied then
						for n,item in ipairs(outs) do
							local name=item:get_name()
							if name~="" and check_recipe_input(inp,name) then
								local iit=ItemStack(item)
								cg[gg.recipe[k]]=iit:take_item(1)
								outsr[n]=iit
								satisfied=true
								break
							end
						end
					end
					if not satisfied then sati=false break end
				end
			end
			if sati then
				local crl=inv:get_list("craft")
				local em={}
				for n=1,9 do
					em[n]=ItemStack()
				end
				for k,v in pairs(gg.replacements) do
					em[k]=ItemStack(v)
				end
				inv:set_list("craft",em)
				local out=ItemStack(recipe.output)
				for k,v in ipairs(minetest.registered_on_crafts) do
					local ccg={}
					for k,v in pairs(cg) do
						ccg[k]=ItemStack(v)
					end
					local oout=v(out,player,ccg,inv)
					if oout~=nil then
						out=oout
					end
				end
				table.insert(outs,out)
				em=inv:get_list("craft",em)
				for k,v in ipairs(em) do
					if v:get_count()>0 then
						table.insert(outs,v)
					end
				end
				for k,v in pairs(outsr) do
					outs[k]=v
				end
				inv:set_list("craft",crl)
				inv:set_list(ilname,il)
				countz=countz+1
			else
				break
			end
		end
	end
	for k,v in ipairs(outs) do
		if v:get_count()>0 then
			local left=inv:add_item(olname,ItemStack(v))
			if left:get_count()>0 then
				minetest.log("log", v)
				minetest.item_drop(left,dropper,pos)
			end
		end
	end
	return countz
end
