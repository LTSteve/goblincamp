extends Node3D

class_name HeightComponent

@export var offset:float = 0
@export var once: bool = false

var _once = false

func _process(_delta):
	if once:
		if _once:
			return
		else:
			_once = true
	global_position.y = get_height()

func get_height():
	return offset + Ground.sample_height(global_position.x, global_position.z)
