-- twist.lua

local function get_bounds(dirs, rivers)
	local X, Y = dirs.X, dirs.Y
	local bounds_x = {X=X, Y=Y}
	local bounds_y = {X=X, Y=Y}
	for i=1, X*Y do
		bounds_x[i] = 0
		bounds_y[i] = 0
	end

	for i=1, X*Y do
		local dir = dirs[i]
		local river = rivers[i]
		if dir == 1 then -- South (+Y)
			bounds_y[i] = river
		elseif dir == 2 then -- East (+X)
			bounds_x[i] = river
		elseif dir == 3 then -- North (-Y)
			bounds_y[i-X] = river
		elseif dir == 4 then -- West (-X)
			bounds_x[i-1] = river
		end
	end

	return bounds_x, bounds_y
end

local function twist(dirs, rivers, n)
	n = n or 5
	local X, Y = dirs.X, dirs.Y
	local bounds_x, bounds_y = get_bounds(dirs, rivers)
	local dn = 0.5 / n

	local offset_x = {X=X, Y=Y}
	local offset_y = {X=X, Y=Y}
	local offset_x_alt = {X=X, Y=Y}
	local offset_y_alt = {X=X, Y=Y}
	for i=1, X*Y do
		offset_x[i] = 0
		offset_y[i] = 0
	end

	for nn=1, n do
		local i = 1
		for y=1, Y do
			for x=1, X do
				local ox, oy = offset_x[i], offset_y[i]
				if dirs[i] ~= 0 and rivers[i] > 1 then
					local sum_fx = 0
					local sum_fy = 0
					local sum_w = 0
					local b
					if x < X then
						b = bounds_x[i]
						sum_fx = sum_fx + b*(offset_x[i+1]+1)
						sum_fy = sum_fy + b*offset_y[i+1]
						sum_w = sum_w + b
					end
					if y < Y then
						b = bounds_y[i]
						sum_fx = sum_fx + b*offset_x[i+X]
						sum_fy = sum_fy + b*(offset_y[i+X]+1)
						sum_w = sum_w + b
					end
					if x > 1 then
						b = bounds_x[i-1]
						sum_fx = sum_fx + b*(offset_x[i-1]-1)
						sum_fy = sum_fy + b*offset_y[i-1]
						sum_w = sum_w + b
					end
					if y > 1 then
						b = bounds_y[i-X]
						sum_fx = sum_fx + b*offset_x[i-X]
						sum_fy = sum_fy + b*(offset_y[i-X]-1)
						sum_w = sum_w + b
					end
					local fx, fy = sum_fx/sum_w - ox, sum_fy/sum_w - oy
					local fd = (fx*fx+fy*fy) ^ 0.5
					if fd > dn then
						local c = dn/fd
						fx, fy = fx*c, fy*c
					end

					offset_x_alt[i] = ox+fx
					offset_y_alt[i] = oy+fy
				else
					offset_x_alt[i] = ox
					offset_y_alt[i] = oy
				end

				i = i + 1
			end
		end
		offset_x, offset_x_alt = offset_x_alt, offset_x
		offset_y, offset_y_alt = offset_y_alt, offset_y
	end

	return offset_x, offset_y
end

return twist
