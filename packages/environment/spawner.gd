@tool
extends Node

@export var mesh:Node;
@export var update = true;
@export_range(0,1.0) var  distribute_density:float = 0.5; 

var rng = RandomNumberGenerator.new()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if update:
		spawn_objs()
		update = false;
		
@export var nodes = [];

func spawn_objs():
	print_debug("spawner")
	
	var meshdata = mesh.get_mesh();
	var faces = meshdata.get_faces();
	
	var index = 0;
	
	
	while (index<faces.size()):
		
		var p0 = faces[index]
		var p1 = faces[index+1]
		var p2 = faces[index+2]
		
		
		var among = among_on_face(p0,p1,p2,distribute_density);
		
		print_debug(among)
		
		#var wight = get_barycentric_coordinates()
		#var p = interp_v3_v3v3v3(p0,p1,p2,wight)
		#spawn_obj(p)
		
		index+=3
	
	
	#print_debug(faces)
	
	#spawn_obj(faces[0])
	#for vtx in range(meshdata.get_vertex_count()):
	#	var vert= meshdata.get_vertex(vtx)
	#	print_debug(vert)
	
func spawn_obj(position:Vector3):
	
	var sphere = MeshInstance3D.new()
	
	add_child(sphere)
	
	sphere.owner = get_tree().edited_scene_root
	
	sphere.position = position
	
	
	#sphere.set_mesh(SphereMesh.new())
	
	#sphere.position = position
	
	#sphere.name = "aaa"

func among_on_face(v1, v2, v3, density:float):
	
	var area = area_tri_v3(v1,v2,v3)
	
	return round_probabilistic(area * density)


func get_barycentric_coordinates():
	
	if(!rng):
		rng = RandomNumberGenerator.new()
	
	var rand1 =rng.randf()
	var rand2 =rng.randf()
	
	if (rand1 + rand2 > 1.0):
		rand1 = 1.0 - rand1;
		rand2 = 1.0 - rand2;
	
	return Vector3(rand1,rand2,1.0 - rand1 - rand2);

func round_probabilistic(x):
	
	if(!rng):
		rng = RandomNumberGenerator.new()
		
	var round_up_probability = x - floor(x)
	
	if(round_up_probability > rng.randf()):
		return int(x)+1
	else :
		return int(x)

func area_tri_v3(v1, v2, v3):
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

# Rand position on face
func interp_v3_v3v3v3(v1, v2, v3, w):
	var p = Vector3()
	
	p[0] = v1[0] * w[0] + v2[0] * w[1] + v3[0] * w[2];
	p[1] = v1[1] * w[0] + v2[1] * w[1] + v3[1] * w[2];
	p[2] = v1[2] * w[0] + v2[2] * w[1] + v3[2] * w[2];
	
	return p;
	
