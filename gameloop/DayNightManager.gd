extends Node

class_name DayNightManager

static var I: DayNightManager

@export var environment:Environment
@export var light_sources: Array[DirectionalLight3D]

var _dayness:float = 1.0
var _target_dayness: float = 1.0

var _light_source_full: Array[float]
var _light_source_half: Array[float]

func _ready():
	I = self
	for light_source in light_sources:
		_light_source_full.append(light_source.light_energy)
		_light_source_half.append(light_source.light_energy * 0.4)

func _move_to_night(_day):
	_target_dayness = 0

func _move_to_day():
	_target_dayness = 1

func _process(delta):
	if _target_dayness == _dayness: return
	
	_dayness = lerpf(_dayness, _target_dayness, (delta * 0.25) if _target_dayness == 0 else (delta * 0.5))
	
	_apply_dayness(_dayness)

func _apply_dayness(dayness):
	environment.sky.sky_material.set_shader_parameter("Dayness", dayness)
	for i in light_sources.size():
		var light_source = light_sources[i]
		light_source.light_energy = lerpf(_light_source_half[i], _light_source_full[i], dayness)
