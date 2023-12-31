extends Node

class_name DayNightManager

static var I: DayNightManager

@export var environment:Environment
@export var light_sources: Array[DirectionalLight3D]

@export var is_day_resource: ObservableResource

var _dayness:float = 1.0
var _target_dayness: float = 1.0

var _light_source_full: Array[float]
var _light_source_half: Array[float]

func _ready():
	I = self
	
	for light_source in light_sources:
		_light_source_full.append(light_source.light_energy)
		_light_source_half.append(light_source.light_energy * 0.3)
	
	is_day_resource.value_changed.connect(_on_day_changed)

func _on_day_changed(is_day, _was_day):
	_target_dayness = 1 if is_day else 0
	set_process(true)

func _process(delta):
	_dayness = clampf(lerpf(_dayness, _target_dayness, (delta * 0.33) if _target_dayness == 0 else (delta * 0.5)), 0, 1)
	
	_apply_dayness(_dayness)
	
	if _dayness == _target_dayness:
		set_process(false)

func _apply_dayness(dayness):
	if !environment.sky: return
	environment.sky.sky_material.set_shader_parameter("Dayness", dayness)
	for i in light_sources.size():
		var light_source = light_sources[i]
		light_source.light_energy = lerpf(_light_source_half[i], _light_source_full[i], dayness)
