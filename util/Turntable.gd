class_name Turntable

extends Node

@onready var to_rotate: Node3D = $".."

@export var rotation_speed_degrees_per_second: float = 90.0

@export var rotation_axis: Vector3 = Vector3.UP

@export var start_active: bool = false

func _ready():
	if !start_active: set_process(false)

func _process(delta):
	to_rotate.rotate(Vector3.UP, deg_to_rad(delta * rotation_speed_degrees_per_second))
