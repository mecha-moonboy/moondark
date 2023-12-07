if minetest.registered_crafts then return end 
  -- ^ mintest is sane (yay), nothing to do

local first=true
local cou=0
for k,v in pairs(minetest.registered_items) do
	if minetest.get_all_craft_recipes(k) then
		first=false
	end
end

assert(first,
"some mods loaded and have registered crafting recipes before the" ..
" craft hook could catch them. fail. dieing. committing self-destruct.")

local rc=minetest.register_craft
local ec=minetest.clear_craft

local function hashinput(recipe)
	local inp=recipe.recipe
	if not inp then return "" end
	if type(inp)=="string" then
		inp={inp}
	end
	if type(inp[1])=="string" then
		inp={inp}
	end
	local str={}
	for y,v in ipairs(inp) do
		local s={}
		for x,v in ipairs(v) do
			if type(v)~="string" then
				error(dump{inp=inp,recipe=recipe})
			end
			table.insert(s,minetest.encode_base64(v))
		end
		table.insert(str,table.concat(s,","))
	end
	return table.concat(str,"\n")
end
local craftsbyinput={}

function minetest.register_craft(...)
	local t={rc(...)}
	local recipe=...
	do
		cou=cou+1
		recipe._reg_order=cou
		local out=ItemStack(recipe.output):get_name()
		local t=minetest.registered_crafts[out] or {}
		t[recipe]=true
		minetest.registered_crafts[out]=t
	end
	return unpack(t)
end

function minetest.clear_craft(...)
	local t={ec(...)}
	local recipe=...
	if t[1] then
		if recipe.output then
			local out=ItemStack(recipe.output):to_string()
			local crafts=minetest.registered_crafts[out]
			for k,v in pairs(crafts) do
				crafts[k]=nil
			end
		elseif recipe.recipe then
			local clearables={}
			local t=minetest.registered_crafts
			for out,crafts in pairs(t) do
				for r,_ in pairs(crafts) do
					if ((recipe.type==r.type) or not recipe.type) and (hashinput(recipe)==hashinput(r)) then
						crafts[r]=nil
						if not next(crafts) then
							clearables[out]=true
						end
					end
				end
			end
			for k,v in pairs(clearables) do
				t[k]=nil
			end
		end
	end
	return unpack(t)
end

minetest.registered_crafts={}

minetest.after(1,function()
	minetest.safe_file_write(minetest.get_worldpath().."/recipes.txt",dump(minetest.registered_crafts))
end)
