@tool

extends Node3D

class_name Ground

static var I: Ground

@export var re_render: bool:
	set(_value):
		re_render = false
		_on_data_changed()
		if planet_data != null && !planet_data.is_connected("changed",_on_data_changed):
			planet_data.connect("changed",_on_data_changed)

@export var planet_data : PlanetData
@export var face: GroundMesh
@export var random_seed: bool = true
@export var specific_seed: int = 0

func _ready():
	_on_data_changed()
	I = self

func _on_data_changed():
	if random_seed:
		planet_data.noise_layers.assign_seed(randi())
	else:
		planet_data.noise_layers.assign_seed(specific_seed)
	face.regenerate_mesh(planet_data)

static func sample_height(x:float,y:float) -> float:
	return I.face.sample_height((x - I.global_position.x) / I.scale.x,(y - I.global_position.z) / I.scale.z)

