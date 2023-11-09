extends Node3D

class_name HeightComponent

@export var offset:float = 0
@export var once: bool = false

func _process(_delta):
	global_position.y = get_height()
	
	if once:
		set_process(false)

func get_height():
	return offset + Ground.sample_height(global_position.x, global_position.z)
