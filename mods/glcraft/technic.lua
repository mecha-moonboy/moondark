local E=...
if minetest.get_modpath("technic") then
	local icons={
		separating="technic_mv_centrifuge_front.png",
		compressing="technic_mv_compressor_front.png",
		extracting="technic_mv_extractor_front.png",
		alloy="technic_mv_alloy_furnace_front.png",
		freezing="technic_mv_freezer_front.png",
		grinding="technic_mv_grinder_front.png",
	}
	local technic_recipes={}
	local function serialize_technic_recipe(typename,recipe)
		local o={type="custom"}
		local rt=technic.recipes[typename]
		local rtd=rt and rt.description or typename
		local rti=icons[typename] or "technic_machine_casing.png"
		o.recip_icon={icon=rti,tooltip=rtd}
		local inp,out=recipe.input,recipe.output
		if type(inp)=="string" then
			inp={inp}
		end
		if type(out)=="string" then
			out={out}
		end
		local inp,ii={},inp
		for k,v in pairs(ii) do
			for n=1,v do
				table.insert(inp,k)
			end
		end
		o.inputs=E.shapeless_gridify(inp)
		o.outputs=E.gridify_list(out)
		return o
	end
	local function scan_technic_recipes()
		for k,v in pairs(technic_recipes) do
			for it,_ in pairs(v.its) do
				E.recipes_custom[it][v.recipe]=nil
			end
		end
		technic_recipes={}
		for typename,v in pairs(technic.recipes) do
			if v.recipes then
				for _,recipe in pairs(v.recipes) do
					local recip=serialize_technic_recipe(typename,recipe)
					local rrr={recipe=recip,its={}}
					technic_recipes[recipe]=rrr
					for y,v in pairs(recip.outputs) do
						for y,v in pairs(v) do
							local it=ItemStack(v):get_name()
							if it~="" then
								E.recipes_custom[it]=E.recipes_custom[it] or {}
								E.recipes_custom[it][recip]=true
								rrr.its[it]=true
							end
						end
					end
					E.plan_recipe_scan()
				end
			end
		end
	end
	local plan_tr_scan,scan_tr_now = E.plan_f(scan_technic_recipes)
	local trr=technic.register_recipe
	function technic.register_recipe(...)
		local after=minetest.after
		local function badafter(s,fn,...)
			return after(s,function(...)plan_tr_scan() return fn(...)end,...)
		end
		minetest.after=badafter
		local ret={trr(...)}
		minetest.after=after
		return unpack(ret)
	end
	minetest.after(0.01,plan_tr_scan)
end
