@tool

extends Node3D

class_name Ground

static var I: Ground

@export var re_render: bool:
	set(value):
		re_render = false
		_on_data_changed()
		if planet_data != null && !planet_data.is_connected("changed",_on_data_changed):
			planet_data.connect("changed",_on_data_changed)

@export var planet_data : PlanetData

func _ready():
	_on_data_changed()
	I = self

func _on_data_changed():
	for child in get_children():
		var face: GroundMesh = child as GroundMesh
		face.regenerate_mesh(planet_data)

static func sample_height(x:float,y:float) -> float:
	var face: GroundMesh = I.get_children()[0] as GroundMesh
	return face.sample_height((x - I.global_position.x) / I.scale.x,(y - I.global_position.z) / I.scale.z)
