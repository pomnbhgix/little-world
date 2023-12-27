@tool
extends Node3D

@export var update = true;

@export var placement_objects_parent:Node3D;
@export_range(0,1000) var max_sample_pos:int = 500
@export var distance_range = 10.0
@export var tree_paths:Array[String] = []
@export var rock_paths:Array[String] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if update:
		
		#clear_placement_objects();
		if !placement_objects_parent:
			create_placement_objects_parent()
		else :
			clear_placement_objects()
		
		placement_objects();
		
		update = false;

func placement_objects():
	
	if !placement_objects_parent:
		create_placement_objects_parent()
	
	var _placement_positions:Array[Vector3] = []
	
	var tree_positions = MeshUtils.create_positions_on_sphere(max_sample_pos)
	tree_positions = MeshUtils.clear_close_positionv2(tree_positions,1.0,distance_range/25.0)
	for pos in tree_positions:
		spawn_tree(pos * 24.9 )
	
	var rock_positions = MeshUtils.create_positions_on_sphere(max_sample_pos)
	rock_positions = MeshUtils.clear_close_positionv2(tree_positions,1.0,distance_range/40.0)
	for pos in rock_positions:
		spawn_rock(pos * 24.9)
	
func create_placement_objects_parent():
	placement_objects_parent = Node3D.new()
	placement_objects_parent.name = "PlacementObjectsParent"
	add_child(placement_objects_parent)
	placement_objects_parent.owner = get_tree().edited_scene_root
	
func clear_placement_objects():
	if placement_objects_parent:
		for obj in placement_objects_parent.get_children():
			obj.queue_free()
	
func spawn_tree(pos:Vector3):
	var index = randi() % 5
	var node_instance = spawn_obj(tree_paths[index],pos)
	node_instance.basis = Quaternion(Vector3.UP,(pos - self.global_transform.origin).normalized()) 
	
func spawn_rock(pos:Vector3):
	var index = 0
	var node_instance = spawn_obj(rock_paths[index],pos)
	node_instance.basis = Quaternion(Vector3.UP,(pos - self.global_transform.origin).normalized())
	
func spawn_obj(node_path:String,pos:Vector3) -> Node3D:
	var node_instance = load(node_path).instantiate()
	placement_objects_parent.add_child(node_instance)
	node_instance.owner = get_tree().edited_scene_root
	node_instance.position = pos
	return node_instance
