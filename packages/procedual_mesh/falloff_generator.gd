extends Node

class_name FalloffGenerator;

static func evaluate_falloff(x,y,size_x,size_y):
	var value_0 = x / float(size_x) * 2 - 1;
	var value_1 = y / float(size_y) * 2 - 1;
	var value = max(abs(value_0),abs(value_1))
	
	const a = 3.0;
	const b = 2.2;
	return pow(value,a) / (pow(value,a) + pow (b - b * value, a))
	
static func generate_falloff_map(size_x,size_y):
	var map = [];
	
	for i in size_x:
		map.append([])
		for j in size_y:
			map[i].append(evaluate_falloff(i,j,size_x,size_y))
			
	return map


