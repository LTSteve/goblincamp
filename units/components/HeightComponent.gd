extends Node3D

class_name HeightComponent

@export var offset:float = 0

func _process(delta):
	global_position.y = offset + Ground.sample_height(global_position.x, global_position.z)
