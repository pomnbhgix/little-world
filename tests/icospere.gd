@tool
extends MeshInstance3D

@export var update = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update:
		print_debug("tool test")
		update =  false
	
