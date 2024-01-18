extends Node3D

class_name HeightComponent

signal after_first_height_set()

@export var offset:float = 0
@export var once: bool = false

var _was_set = false

func _process(_delta):
	global_position.y = get_height()
	
	if !_was_set:
		after_first_height_set.emit()
		_was_set = true
	
	if once:
		set_process(false)

func get_height():
	return offset + Ground.sample_height(global_position.x, global_position.z)
