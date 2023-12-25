extends Node

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
	
	func find_all_node_in_range(position,range):
		var co = position;
		var stack:Array[int] = [];
		var range_sq = range * range
		var dist_sq = 0.0;
		var result  = [];
		
		stack.append(root_index)
		
		while !stack.is_empty():
			var node_index = stack.pop_back();
			var node = nodes[node_index]
			
			if co[node.d]+range < node.value[node.d]:
				if node.left != -1:
					stack.append(node.left)
			
			elif co[node.d] - range > node.value[node.d]:
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
			var len = v0[i] - v1[i];
			d += len * len;
		
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
	
	func  _init(position: Vector3):
		value.append(position.x);
		value.append(position.y);
		value.append(position.z);
	
	
	
