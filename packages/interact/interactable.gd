extends Node3D

@export var actions : Array[InteractAction]
@export var default_description : String = "Get Item"
@export var droped_item : String;
@export var interact_count : int = 3;

@onready var animation_player = $AnimationPlayer

func get_actions(_interactor : InventoryInteractor) -> Array[InteractAction]:
	actions[0].description = default_description
	return actions

func interact(_interactor : InventoryInteractor, _action_index : int = 0):
	if interact_count > 0:
		animation_player.play("shake")
		interact_count -= 1;
	else:
		if droped_item:
			var obj = load(droped_item).instantiate()
			obj.position = self.position
			get_tree().root.add_child(obj)
			self.queue_free()
