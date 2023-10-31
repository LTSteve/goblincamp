extends Node

class_name MaterialOverrideComponent

@export var mesh_instance: MeshInstance3D

var _material:BaseMaterial3D

var _base_emission_color: Color
var _base_color: Color

var _emission_color_stack: Array[Color] = []
var _color_stack: Array[Color] = []

var _use_emission: bool

func _ready():
	# emission doesn't work on web i guess
	_use_emission = !OS.has_feature("web")
	
	_material = mesh_instance.get_active_material(0).duplicate() as BaseMaterial3D
	mesh_instance.set_surface_override_material(0, _material)
	_base_emission_color = _material.emission
	_base_color = _material.albedo_color
	
	if _use_emission:
		_material.emission_energy_multiplier = 0.3

func get_material() -> BaseMaterial3D:
	return _material

func _process(_delta):
	if _use_emission:
		if _emission_color_stack.size() == 0:
			_material.emission_enabled = false
		else:
			_material.emission_enabled = true
			_material.emission = _emission_color_stack.reduce(func(accum,color):
				return color + accum, _base_emission_color)
	
	if _color_stack.size() > 0:
		_material.albedo_color = _color_stack.reduce(func(accum,color):
			return color + accum, Color.BLACK)
	else:
		_material.albedo_color = _base_color

func add_color(color:Color):
	if _color_stack.has(color): return
	_color_stack.append(color)

func remove_color(color:Color):
	var index = _color_stack.find(color)
	if index == -1: return
	_color_stack.remove_at(index)

func add_emission_color(color:Color):
	if !_use_emission: 
		add_color(color)
		return
	
	if _emission_color_stack.has(color): return
	_emission_color_stack.append(color)

func remove_emission_color(color:Color):
	if !_use_emission: 
		remove_color(color)
		return
	
	var index = _emission_color_stack.find(color)
	if index == -1: return
	_emission_color_stack.remove_at(index)
