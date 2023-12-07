--m*rebl*cks
local E=...

local table_eq=E.table_eq
E.cg_blacklisted_items={}
E.cg_blacklisted_recipes={}
local count=0
local rcount=0

local mbpath=minetest.get_modpath("moreblocks")
local tcpath=minetest.get_modpath("technic_cnc")
local enpath=minetest.get_modpath("extranodes")
local copath=minetest.get_modpath("concrete")
local scpath=minetest.get_modpath("scifi_nodes")
local stpath=minetest.get_modpath("stairs")

if mbpath or tcpath or stpath then
	local regnode,regrecip,regali,regali_force,reglbm,regdnodes=
		minetest.register_item,
		minetest.register_craft,
		minetest.register_alias,
		minetest.register_alias_force,
		minetest.register_lbm,
		minetest.registered_nodes

	local ccdn={}
	for k,v in pairs(regdnodes) do
		ccdn[k]=table.copy(v)
	end

	local function dontenv()
		minetest.register_item,
		minetest.register_craft,
		minetest.register_alias,
		minetest.register_alias_force,
		minetest.register_lbm,
		minetest.registered_nodes =
		function()end,
		function()end,
		function()end,
		function()end,
		function()end,
		ccdn
	end

	local function fakeenv()
		minetest.registered_nodes=ccdn
		minetest.register_item=function(name,def)
			local name=name:sub(1,1)==":" and name:sub(2) or name
			if not E.cg_blacklisted_items[name] then
				count=count+1
			end
			E.cg_blacklisted_items[name]=true
		end
		minetest.register_alias=minetest.register_item
		minetest.register_alias_force=minetest.register_alias
		minetest.register_alias=function()end
		minetest.register_craft=function(recip)
			for k,v in pairs(minetest.registered_crafts[ItemStack(recip.output):get_name()] or {}) do
				local k2=table.copy(k)
				k2._reg_order=nil
				if table_eq(k2,recip) then
					if not E.cg_blacklisted_recipes[k] then
						rcount=rcount+1
					end
					E.cg_blacklisted_recipes[k]=true
				end
			end
		end
		minetest.register_lbm=function()end
	end

	local function realenv()
		minetest.registered_nodes=regdnodes
		minetest.register_item=regnode
		minetest.register_craft=regrecip
		minetest.register_alias=regali
		minetest.register_alias_force=regali_force
		minetest.register_lbm=reglbm
	end

	local recips={}
	local nodes={}
	
	if mbpath then
		fakeenv()
		dofile(mbpath.."/stairsplus/registrations.lua")
		dontenv()
		local spra=stairsplus.register_all
		function stairsplus.register_all(...)
			fakeenv()
			spra(...)
			dontenv()
		end
		dofile(mbpath.."/nodes.lua")
		if enpath then
			dofile(enpath.."/init.lua")
		end
		if scpath then
			dofile(scpath.."/models.lua")
		end
		if copath then
			local file=io.open(copath.."/init.lua")
			local line=file:read()
			local lines={}
			local reading=false
			while line do
				if line=="if minetest.get_modpath(\"moreblocks\") then" then
					reading=true
				end
				if reading then
					table.insert(lines,line)
				end
				if line=="end" then
					reading=false
				end
				line=file:read()
			end
			loadstring(table.concat(lines,"\n"))()
		end
		stairsplus.register_all=spra
		realenv()
	end
	if tcpath then
		fakeenv()
		dofile(tcpath.."/materials/init.lua")
		realenv()
	end
	if stpath then
		fakeenv()
		local file=io.open(stpath.."/init.lua")
		local line=file:read()
		local lines={}
		local reading=false
		while line do
			if line=="-- Stair/slab registration function." then
				reading=true
			end
			if reading then
				table.insert(lines,line)
			end
			line=file:read()
		end
		local str="local S = minetest.get_translator(\"stairs\")\nlocal T=S"..
		"\nwarn_if_exists=function()end"..table.concat(lines,"\n")
		loadstring(str)()
		realenv()
	end

	print(count.." M*REBL*CKS/T*CHN*C_CNC GARBAGE SLABS BLACKLISTED, "..rcount.." RECIPES")
end
