extends Node3D

class_name InverseHeightComponent

@export var offset:float = 0
@export var once: bool = false

func _process(_delta):
	global_position.y = offset
	if once:
		set_process(false)
