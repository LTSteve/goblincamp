extends Behaviour

class_name MeleeBehaviour

@export var comfortable_range_modifier:float = 0.5

func initialize(brain:BrainComponent):
	brain.weapons = _bind_to_all_weapons(brain)
	return brain.weapons[0] if brain.weapons.size() else null

func assign_target(_delta, brain:BrainComponent, _weapon):
	var had_no_target = !brain.target
	
	brain.target = Global.nearest_unit(Global.players, brain.unit.global_position) if brain.unit.is_enemy else Global.nearest_unit(Global.enemies, brain.unit.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target && had_no_target:
		brain.enter_combat.emit()
	
	if !brain.target:
		brain.exit_combat.emit()

func process(_delta, brain:BrainComponent, weapon):
	if brain.target && weapon:
		if brain.unit.global_position.distance_to(brain.target.global_position) > weapon.weapon_range * comfortable_range_modifier:
			brain.unit.set_movement_target(brain.target.global_position)
		else:
			brain.unit.set_movement_target(brain.unit.global_position)
		brain.request_attack.emit(brain.target,brain.unit)
		return true
	
	return false
