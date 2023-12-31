@tool
@icon("res://addons/inventory-system/icons/interactor.svg")
class_name InventoryInteractor
extends NodeInventorySystemBase

signal preview_interacted(actions : Array[InteractAction], position_screen : Vector2)
signal clear_preview
signal interacted(object : Node)

@export_node_path("InventoryHandler") var inventory_handler_path := NodePath("../InventoryHandler")
@onready var inventory_handler : InventoryHandler = get_node(inventory_handler_path)
@export_node_path("Hotbar") var hotbar_path := NodePath("../Hotbar")
@onready var hotbar : Hotbar = get_node(hotbar_path)
@export var raycast : RayCast3D
@export var camera_3d : Camera3D

var last_interact_object : Node
var actual_hand_object : Node


## 🫴 Interact System
func try_interact():
	var object = raycast.get_collider()
	last_interact_object = object
	var pos : Vector2 = Vector2.ZERO
	if object != null and object.has_method("get_interaction_position") and camera_3d != null:
		pos = camera_3d.unproject_position(object.get_interaction_position(raycast.get_collision_point()))
	
	if not raycast.is_colliding():
		clear_preview.emit()
		return
	
	var node = object as Node
	
#		clear_preview.emit()
	
	var actions = get_actions(node)
	var hand_actions = get_hand_actions(actual_hand_object)
	var total_actions : Array[InteractAction] = []
	total_actions.append_array(actions)
	total_actions.append_array(hand_actions)
	preview_interacted.emit(total_actions, pos)
	
	interact_object(object, actions)
	interact_hand_item(actual_hand_object, hand_actions)


func get_actions(node : Node) -> Array[InteractAction]:
	var actions : Array[InteractAction] = []
	if node != null and node.has_method("get_actions"):
		actions = node.get_actions(self)
	return actions


func get_hand_actions(node : Node) -> Array[InteractAction]:
	var actions : Array[InteractAction] = []
	if node != null and node.has_method("get_actions"):
		actions = node.get_actions(self)
	return actions


func interact_object(object : Node, actions : Array[InteractAction]):
	for action in actions:
		if Input.is_action_just_pressed(action.input):
			object.interact(self, action.code)
			return


func interact_hand_item(hand_object, hand_actions):
	for action in hand_actions:
		if Input.is_action_just_pressed(action.input):
			hand_object.interact(self, action.code)
			return
