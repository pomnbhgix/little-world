extends Node3D

@export var actions : Array[InteractAction]
@export var default_description : String = "Get Item"

func get_actions(_interactor : InventoryInteractor) -> Array[InteractAction]:
	actions[0].description = default_description
	return actions

func interact(_interactor : InventoryInteractor, _action_index : int = 0):
	print_debug("chop")
