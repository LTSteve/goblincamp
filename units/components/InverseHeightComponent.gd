extends Node3D

class_name InverseHeightComponent

@export var offset:float = 0

func _process(delta):
	global_position.y = offset
