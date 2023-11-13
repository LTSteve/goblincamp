extends CardModifier

class ColdSteelEffect extends Effect:
	
	var _velocity_component: VelocityComponent
	var _slow: float
	
	func _init(weapon_hit: Weapon.Hit, effect_duration: float, effect_id: String, slow: float):
		super._init(weapon_hit.hit, effect_duration, false, effect_id)
		
		_velocity_component = unit.find_child("VelocityComponent") as VelocityComponent
		if _velocity_component.get_max_speed.has_override([id, "_get_max_speed_override"]): return
		
		_slow = slow
		_velocity_component.get_max_speed.add_override([id, "_get_max_speed_override"],_get_max_speed_override)
	
	func on_apply():
		unit.add_state(Unit.State.CHILLED)
	
	func _get_max_speed_override(_base_max_speed:float, current_max_speed:float):
		return clampf(current_max_speed - _slow, 0.05, _base_max_speed)
	
	func on_remove():
		if !is_instance_valid(_velocity_component): return
		
		unit.remove_state(Unit.State.CHILLED)
		
		_velocity_component.get_max_speed.remove_override([id, "_get_max_speed_override"])

func _apply(weapon:Weapon,_unit:Unit):
	# just a little later so we can't shatter on the first hit
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override, 2)

func _un_apply(weapon:Weapon,_unit:Unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	#apply effect to weapon_hit.unit
	if current_value.damage > 0:
		var effect = ColdSteelEffect.new(current_value, params.duration, UniqueMetaId.create([self]), 1.0 - params.slow_per_rank * current_rank)
		current_value.hit.add_effect(effect)
	return current_value
