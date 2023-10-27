extends Behaviour

class_name ChannelingBehaviour

@export var flee_distance:float = 8
@export var flee_speed_scale: float = 0.8

func initialize(brain:BrainComponent):
	brain.weapons += _bind_to_all_weapons(brain,typeof(ChannelingWeapon))
	return brain.weapons[0] if brain.weapons.size() else null

func assign_target(_delta, brain:BrainComponent, _weapon):
	var had_no_target = !brain.target
	
	brain.target = Global.nearest_unit(Global.players if brain.unit.is_enemy else Global.enemies, brain.unit.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target && had_no_target:
		brain.enter_combat.emit()
	
	if !brain.target:
		#brain.request_attack_rewind.emit()
		brain.exit_combat.emit()

func process(_delta, brain:BrainComponent, weapon:ChannelingWeapon):
	if !brain.target || !weapon:
		if weapon._active_aoe:
			brain.end_channeling.emit()
		return false
	
	if !weapon._active_aoe:
		brain.begin_channeling.emit()
	
	var desired_locations = []
	
	var fleeing = false
	for enemy in brain.fleeing:
		fleeing = true
		desired_locations.append(enemy.global_position + Math.unit_v3(brain.unit.global_position - enemy.global_position) * flee_distance)
	
	if fleeing:
		var location_sum = Vector3.ZERO
		for location in desired_locations:
			location_sum += location
	
		brain.unit.set_movement_target(location_sum / max(desired_locations.size(),1), flee_speed_scale if fleeing else 1.0)
		return true
	
	return false
