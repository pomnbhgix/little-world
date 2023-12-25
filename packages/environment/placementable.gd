@tool
extends MeshInstance3D

@export var update = true;

@export_range(0,1000) var max_sample_pos:int = 500
@export var distance_range = 10.0

@export var tree_paths:Array[String] = []
@export var rock_paths:Array[String] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		
		for obj in get_children():
			obj.queue_free();
		
		placement_objects()
		
		update = false;

func create_positions_on_sphere(position_num:int):
	var positions:Array[Vector3] = []
	
	for i in position_num:
		positions.append(MeshUtils.random_on_unit_sphere())
		
	return positions;

func placement_objects():
	
	var _placement_positions:Array[Vector3] = []
	
	var tree_positions = create_positions_on_sphere(max_sample_pos)
	tree_positions = MeshUtils.clear_close_positionv2(tree_positions,1.0,distance_range/25.0)
	for pos in tree_positions:
		spawn_tree(pos * 25.0)
	
	var rock_positions = create_positions_on_sphere(max_sample_pos)
	rock_positions = MeshUtils.clear_close_positionv2(tree_positions,1.0,distance_range/40.0)
	for pos in rock_positions:
		spawn_rock(pos * 25.0)
	


func spawn_tree(pos:Vector3):
	
	var index = randi() % 5
	
	var direction = (pos - self.global_transform.origin).normalized()
	
	var node = load(tree_paths[index])
	var node_instance = node.instantiate()
	add_child(node_instance)
	node_instance.owner = get_tree().edited_scene_root
	node_instance.position = pos
	
	node_instance.basis = Quaternion(Vector3.UP,direction) 
	

func spawn_rock(pos:Vector3):
	
	#var index = randi() % 5
	var index = 0;
	var direction = (pos - self.global_transform.origin).normalized()
	var node = load(rock_paths[index])
	var node_instance = node.instantiate()
	add_child(node_instance)
	node_instance.owner = get_tree().edited_scene_root
	node_instance.position = pos
	node_instance.basis = Quaternion(Vector3.UP,direction) 
