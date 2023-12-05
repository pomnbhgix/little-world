@tool
extends Node

var first = true;

func _process(_delta):
	if first:
		DisplayServer.window_set_min_size(Vector2i.ZERO)
		first = false

