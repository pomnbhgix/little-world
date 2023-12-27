extends Node

class_name MeshUtils;

static var rng = RandomNumberGenerator.new() 

static func create_positions_on_sphere(position_num:int):
	var positions:Array[Vector3] = []
	
	for i in position_num:
		positions.append(random_on_unit_sphere())
		
	return positions;

static func random_on_unit_sphere() -> Vector3:
	var x1 = randf_range (-1, 1)
	var x2 = randf_range (-1, 1)
	while x1*x1 + x2*x2 >= 1:
		x1 = randf_range(-1, 1)
		x2 = randf_range(-1, 1)
	var random_pos_on_unit_sphere = Vector3 (
	2 * x1 * sqrt(1 - x1*x1 - x2*x2),
	2 * x2 * sqrt(1 - x1*x1 - x2*x2),
	1 - 2 * (x1*x1 + x2*x2))
	return random_pos_on_unit_sphere

static func sample_mesh_surface(mesh:Mesh,density:float) -> Array[Vector3]:

	density = clampf(density,0,1)

	assert(mesh)

	var triangles = mesh.get_faces()

	var triangle_index = 0 

	var result:Array[Vector3] = []

	while triangle_index < triangles.size():
		var vertex_a = triangles[triangle_index]
		var vertex_b = triangles[triangle_index + 1]
		var vertex_c = triangles[triangle_index + 2]
		triangle_index += 3;

		var area_size = triangle_area_size(vertex_a , vertex_b , vertex_c)
		var sample_num = round_probabilistic(area_size * density)

		while sample_num > 0:
			var wight = get_barycentric_coordinates()
			var position = interp_v3_v3v3v3(vertex_a,vertex_b,vertex_c,wight)
			result.append(position)
			sample_num -= 1;
	
	return result

static func triangle_area_size(v1, v2, v3):
	var n = Vector3()
	var n1 = [0.0,0.0,0.0];
	var n2 = [0.0,0.0,0.0];
	
	n1[0] = v1[0] - v2[0];
	n2[0] = v2[0] - v3[0];
	n1[1] = v1[1] - v2[1];
	n2[1] = v2[1] - v3[1];
	n1[2] = v1[2] - v2[2];
	n2[2] = v2[2] - v3[2];
	
	n[0] = n1[1] * n2[2] - n1[ 2] * n2[1];
	n[1] = n1[2] * n2[0] - n1[0] * n2[2];
	n[2] = n1[0] * n2[1] - n1[1] * n2[0];
	
	return n.length() * 0.5

static func round_probabilistic(x):

	if(!rng):
		rng = RandomNumberGenerator.new()
		
	var round_up_probability = x - floor(x)
	
	if(round_up_probability > rng.randf()):
		return int(x)+1
	else :
		return int(x)

static func get_barycentric_coordinates():
	if(!rng):
		rng = RandomNumberGenerator.new()
	
	var rand1 =rng.randf()
	var rand2 =rng.randf()
	
	if (rand1 + rand2 > 1.0):
		rand1 = 1.0 - rand1;
		rand2 = 1.0 - rand2;
	
	return Vector3(rand1,rand2,1.0 - rand1 - rand2);

static func interp_v3_v3v3v3(v1, v2, v3, w):
	var p = Vector3()
	
	p[0] = v1[0] * w[0] + v2[0] * w[1] + v3[0] * w[2];
	p[1] = v1[1] * w[0] + v2[1] * w[1] + v3[1] * w[2];
	p[2] = v1[2] * w[0] + v2[2] * w[1] + v3[2] * w[2];
	
	return p;

static func clear_close_position(positions:Array[Vector3],pos_range:float):
	var tree = KDTree.new(positions)
	
	tree.balance()
	
	var elimination_mask = []
	elimination_mask.resize(positions.size())
	
	for index in tree.nodes.size():
		
		if elimination_mask[index]:
			continue
		
		for  i in tree.find_all_node_in_range(positions[index],pos_range):
			elimination_mask[i] = true;
	
	var result = []
	
	for node_index in tree.nodes.size():
		if !elimination_mask[node_index]:
			result.append(tree.nodes[node_index].to_vector3())
			
	return result
	
static func clear_close_positionv2(positions:Array[Vector3],scale:float,pos_range:float):
	var result:Array[Vector3] = []

	for pos in positions:

		if result.is_empty():
			result.append(pos)
			continue
		
		if result.any(func (r):
			if r.distance_to(pos) * scale < pos_range:
				return true
			else :
				return false):
			continue

		result.append(pos)
	
	return result
	
static func clear_close_position_with_exist(positions:Array[Vector3],exist_position:Array[Vector3],scale:float,pos_range:float):
	var result:Array[Vector3] = []

	for pos in positions:
		
		if exist_position.any(func (r):
			if r.distance_to(pos) * scale < pos_range:
				return true
			else :
				return false):
			continue
		
		if result.any(func (r):
			if r.distance_to(pos) * scale < pos_range:
				return true
			else :
				return false):
			continue

		result.append(pos)
	
	return result

class KDTree:
	var nodes:Array[KDTreeNode] = [];
	var root_index = 0;
	
	func _init(array:Array[Vector3]):
		for v in array:
			nodes.append(KDTreeNode.new(v))
	
	func balance():
		root_index = balance_nodes(0,nodes.size(),0,0)
		
	
	func balance_nodes(start_index, nodes_len, axis, ofs) -> int:
		
		if nodes_len <= 0:
			return -1;
		elif nodes_len == 1:
			return ofs;
			
		var left = start_index;
		var right = start_index + nodes_len - 1;
		var median = nodes_len / 2;
		
		var co :float = 0.0;
		var i = 0;
		var j = 0;
		
		while right > left:
			co = nodes[right].value[axis]
			i = left - 1;
			j = right;
			
			while true:
				while true:
					i += 1 ;
					if nodes[i].value[axis] >= co:
						break;
				
				while true:
					j -= 1;
					if nodes[j].value[axis] <= co || j <= left:
						break;
				
				if i >= j:
					break;
				
				swap_node(i,j)
				
			swap_node(i,j)
			
			if i >= median:
				right = i - 1;
			
			if i <= median:
				left = i + 1;
			
		var node = nodes[start_index + median];
		node.d = axis;
		axis = (axis + 1) % 3;
		
		node.left = balance_nodes(start_index,median,axis,ofs)
		node.right = balance_nodes(start_index + median + 1, (nodes_len - (median + 1)) ,axis, (median + 1) + ofs)
		
		return median + ofs;

	
	func find_all_node_in_range(position,pos_range):
		var co = position;
		var stack:Array[int] = [];
		var range_sq = pos_range * pos_range
		var dist_sq = 0.0;
		var result  = [];
		
		stack.append(root_index)
		
		while !stack.is_empty():
			var node_index = stack.pop_back();
			var node = nodes[node_index]
			
			if co[node.d] + pos_range < node.value[node.d]:
				if node.left != -1:
					stack.append(node.left)
			
			elif co[node.d] - pos_range > node.value[node.d]:
				if node.right != -1:
					stack.append(node.right)
			
			else :
				dist_sq = len_squared_vnvn(node.value, co);
				if dist_sq <= range_sq:
					result.append(node_index)
				
				if node.left != -1:
					stack.append(node.left)
					
				if node.right != -1:
					stack.append(node.right)
					
		return result;
		
		
		
		
	func len_squared_vnvn(v0,v1):
		var d = 0.0;
		
		for i in v0.size():
			var pos_len = v0[i] - v1[i];
			d += pos_len * pos_len;
		
		return d;
		
		
	func swap_node(i,j):
		var node = nodes[i];
		nodes[i] = nodes[j];
		nodes[j] = node;

class KDTreeNode:
	var value:Array[float];
	var left:int = -1;
	var right:int = -1;
	var d:int;
	var status = true
	
	func  _init(position: Vector3):
		value.append(position.x);
		value.append(position.y);
		value.append(position.z);
	
	func to_vector3():
		return Vector3(value[0],value[1],value[2])
	
	
