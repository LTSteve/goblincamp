extends Node

class_name HitblinkComponent

@export var model_holder: Node3D
@export var jiggle_intensity: float = 2
@export var jiggle_time: float = 0.5

var _jiggle: float = 0
var _jiggle_direction: Vector3 = Vector3.ZERO

func _ready():
	set_process(false)

func _on_recieved_hit(weapon_hit:Weapon.Hit):
	_jiggle = 0
	_jiggle_direction = model_holder.to_local(Math.v2_to_v3(weapon_hit.direction) + model_holder.global_position)
	set_process(true)

func _vibration_function(x:float):
	var x_20 = x * 20
	#saw from 0 to 10
	@warning_ignore("integer_division")
	var sawtooth_component = x_20 - ((x_20 as int) / 10) * 10
	#tri from 0 to 5
	var triangle_component = sawtooth_component if sawtooth_component < 5 else (10.0 - sawtooth_component)
	
	return triangle_component / 5.0

func _process(delta):
	_jiggle += delta / jiggle_time
	
	if _jiggle > 1.0:
		model_holder.position = Vector3.ZERO
		_jiggle_direction = Vector3.ZERO
		set_process(false)
	else:
		model_holder.position = _jiggle_direction * jiggle_intensity * _vibration_function(_jiggle*_jiggle) * (1.0 - _jiggle)
