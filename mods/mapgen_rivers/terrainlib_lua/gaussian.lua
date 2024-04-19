-- gaussian.lua

local function get_box_size(sigma, n)
	local v = sigma^2 / n
	local r_ideal = ((12*v + 1) ^ 0.5 - 1) / 2
	local r_down = math.floor(r_ideal)
	local r_up = math.ceil(r_ideal)
	local v_down = ((2*r_down+1)^2 - 1) / 12
	local v_up = ((2*r_up+1)^2 - 1) / 12
	local m_ideal = (v - v_down) / (v_up - v_down) * n
	local m = math.floor(m_ideal+0.5)

	local sizes = {}
	for i=1, n do
		sizes[i] = i<=m and 2*r_up+1 or 2*r_down+1
	end

	return sizes
end

local function box_blur_1d(map, size, first, incr, len, map2)
	local n = math.ceil(size/2)
	first = first or 1
	incr = incr or 1
	len = len or math.floor((#map-first)/incr)+1
	local last = first + (len-1)*incr

	local nth = first+(n-1)*incr
	local sum = 0
	for i=first, nth, incr do
		if i == first then
			sum = sum + map[i]
		else
			sum = sum + 2*map[i]
		end
	end

	local i_left = nth
	local incr_left = -incr
	local i_right = nth
	local incr_right = incr

	map2 = map2 or {}
	for i=first, last, incr do
		map2[i] = sum / size
		i_right = i_right + incr_right
		sum = sum - map[i_left] + map[i_right]
		i_left = i_left + incr_left

		if i_left == first then
			incr_left = incr
		end
		if i_right == last then
			incr_right = -incr
		end
	end

	return map2
end

local function box_blur_2d(map1, size, map2)
	local X, Y = map1.X, map1.Y
	map2 = map2 or {}
	for y=1, Y do
		box_blur_1d(map1, size, (y-1)*X+1, 1, X, map2)
	end
	for x=1, X do
		box_blur_1d(map2, size, x, X, Y, map1)
	end

	return map1
end

local function gaussian_blur_approx(map, sigma, n, map2)
	map2 = map2 or {}
	local sizes = get_box_size(sigma, n)
	for i=1, n do
		box_blur_2d(map, sizes[i], map2)
	end
	return map
end

return {
	get_box_size = get_box_size,
	box_blur_1d = box_blur_1d,
	box_blur_2d = box_blur_2d,
	gaussian_blur_approx = gaussian_blur_approx,
}
