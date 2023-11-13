extends CardModifier

class BloodThirstEffect extends DamageOverTimeEffect:
	var weapons_applied_to
	var velocity_component
	
	var params
	var current_rank
	
	func _init(unit_effected: Unit, _params, _current_rank):
		super._init(unit_effected, null, -_params.healing_per_rank * _current_rank, 1, _params.duration, _params.tick_time, "BloodThirstEffect", Damage.Type.Heal, Unit.State.ENRAGED)
		buff = true
		params = _params
		current_rank = _current_rank
	
	func on_apply():
		super.on_apply()
		weapons_applied_to = unit.find_children("", "Weapon")
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			weapon.create_hit.add_override([self, "_create_hit_override"], _create_hit_override)
		velocity_component = unit.find_child("VelocityComponent") as VelocityComponent
		velocity_component.get_max_speed.add_override([self,"_get_max_speed_override"], _get_max_speed_override)
		velocity_component.get_acceleration.add_override([self,"_get_acceleration_override"], _get_acceleration_override)
	
	func on_remove():
		super.on_remove()
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			weapon.create_hit.remove_override([self, "_create_hit_override"])
		weapons_applied_to = []
	
	func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
		current_value.damage += base_value.damage * params.damage_per_rank * current_rank
		return current_value
	
	func _get_max_speed_override(_base_value: float, current_value: float):
		return current_value * (1.0 + params.movement_speed_per_rank * current_rank)
	
	func _get_acceleration_override(_base_value: float, current_value: float):
		return current_value * (1.0 + params.movement_speed_per_rank * current_rank)

func _apply(_unit,unit:Unit):
	var _on_get_kill_override = _on_get_kill.bind(unit)
	UniqueMetaId.store([unit, self, "_on_get_kill_override"], _on_get_kill)
	unit.on_get_kill.connect(_on_get_kill_override)

func _un_apply(_unit,unit:Unit):
	unit.on_get_kill.disconnect(UniqueMetaId.retrieve([unit, self, "_on_get_kill_override"]))

func _on_get_kill(killer:Unit):
	if !is_instance_valid(killer): return
	# do sphere cast for nearby enemy units
	var nearby_units:Array[Unit] = Global.get_all_units_near_position(Global.enemies, killer.global_position, params.range)
	# apply an effect to all of them
	for unit in nearby_units:
		var effect = BloodThirstEffect.new(unit, params, current_rank)
		unit.add_effect(effect)
