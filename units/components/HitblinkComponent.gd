extends Node

class_name HitblinkComponent

@export var model:MeshInstance3D
@export var flashes_per_second: float = 5

var _hit_blink = 0
var _max_hit_blink = 0
var _material: BaseMaterial3D

func _ready():
	_material = model.get_active_material(0).duplicate() as BaseMaterial3D
	model.set_surface_override_material(0, _material)

func _on_recieved_hit(_direction:Vector2, _damage:float, _pushback:float, hit_stun:float, _crit: bool, _damage_type: Damage.Type):
	_max_hit_blink = hit_stun
	_hit_blink = 0

func _process(delta):
	if _max_hit_blink == 0:
		_hit_blink = 0
		_material.emission_enabled = false
		return
	
	_hit_blink += delta
	
	if _hit_blink >= _max_hit_blink:
		_max_hit_blink = 0
		return
	
	var on_off = ((_hit_blink * flashes_per_second * 2) as int % 2) == 0 
	_material.emission_enabled = on_off
