extends CardModifier

class ColdSteelEffect extends Effect:
	
	var _velocity_component: VelocityComponent
	var _slow: float
	
	func _init(weapon_hit: Weapon.Hit, effect_duration: float, effect_id: String, slow: float):
		id = effect_id
		buff = false
		duration = effect_duration
		unit = weapon_hit.hit
		
		_velocity_component = unit.find_child("VelocityComponent") as VelocityComponent
		if UniqueMetaId.has([_velocity_component, id, "_get_max_speed_override"]): return
		
		UniqueMetaId.store([_velocity_component, id, "_get_max_speed_override"], _velocity_component.get_max_speed.add_override(_get_max_speed_override))
		_slow = slow
	
	func _get_max_speed_override(_base_max_speed:float, current_max_speed:float):
		return clampf(current_max_speed - _slow, 0.05, 1)
	
	func on_remove():
		if !is_instance_valid(_velocity_component): return
		_velocity_component.get_max_speed.remove_override(UniqueMetaId.retrieve([_velocity_component, id, "_get_max_speed_override"]))

func _apply(weapon:MeleeWeapon,_unit:Unit):
	UniqueMetaId.store([weapon, self, "_create_hit_override"], weapon.create_hit.add_override(_create_hit_override))

func _un_apply(weapon:MeleeWeapon,_unit:Unit):
	weapon.create_hit.remove_override(UniqueMetaId.retrieve([weapon, self, "_create_hit_override"]))

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	#apply effect to weapon_hit.unit
	if current_value.damage > 0:
		var effect = ColdSteelEffect.new(current_value, params.duration, UniqueMetaId.create([self]), 1.0 - params.slow_per_rank * current_rank)
		current_value.hit.add_effect(effect)
	return current_value
