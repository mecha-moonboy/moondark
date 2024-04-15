local vec_add, vec_dot, vec_dir, vec_dist, vec_multi, vec_normal,
	vec_round, vec_sub = vector.add, vector.dot, vector.direction, vector.distance,
	vector.multiply, vector.normalize, vector.round, vector.subtract

function md_fauna.find_shore(self)
	local pos = self.object:get_pos()
	if not pos then return end

	local nodes = minetest.find_nodes_in_area(pos, pos:offset(0,10,0), "air") or {}
	if #nodes < 1 then return end
	return nodes[math.random(#nodes)]
end