extends Node

class_name HitblinkComponent

@export var material_override: MaterialOverrideComponent
@export var flashes_per_second: float = 5

var _hit_blink = 0
var _max_hit_blink = 0
var _color = Color.WHITE

func _on_recieved_hit(weapon_hit:Weapon.Hit):
	if weapon_hit.hit_stun == 0: return
	_max_hit_blink = weapon_hit.hit_stun
	_hit_blink = 0

func _process(delta):
	if _max_hit_blink == 0:
		_hit_blink = 0
		material_override.remove_emission_color(_color)
		return
	
	_hit_blink += delta
	
	if _hit_blink >= _max_hit_blink:
		_max_hit_blink = 0
		return
	
	var on_off = ((_hit_blink * flashes_per_second * 2) as int % 2) == 0 
	if on_off:
		material_override.add_emission_color(_color)
	else:
		material_override.remove_emission_color(_color)
