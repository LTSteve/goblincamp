extends Behaviour

class_name RangedBehaviour

@export var comfortable_range_modifier:float = 0.5
@export var flee_distance:float = 8

func initialize(brain:BrainComponent):
	brain.weapons += _bind_to_all_weapons(brain)
	if brain.flee_range:
		brain.flee_range.body_entered.connect(_on_body_entered_flee_range.bind(brain))
		brain.flee_range.body_exited.connect(_on_body_exited_flee_range.bind(brain))
	return brain.weapons[0] if brain.weapons.size() else null

func assign_target(_delta, brain:BrainComponent, _weapon):
	var had_no_target = !brain.target
	
	brain.target = Global.nearest_unit(Global.enemies, brain.unit.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target && had_no_target:
		brain.enter_combat.emit()
	
	if !brain.target:
		brain.exit_combat.emit()
	
	_clean_fleeing_list(brain)

func process(_delta, brain:BrainComponent, weapon):
	if !brain.target || !weapon:
		return false
	
	var target_separation = brain.target.global_position - brain.unit.global_position
	var distance_to_target = target_separation.length()
	
	var desired_locations = []
	
	if distance_to_target > weapon.weapon_range * comfortable_range_modifier:
		desired_locations.append(brain.target.global_position)
	else:
		desired_locations.append(brain.unit.global_position)
	
	for enemy in brain.fleeing:
		desired_locations.append(enemy.global_position + Math.unit_v3(brain.unit.global_position - enemy.global_position) * flee_distance)
	
	var location_sum = Vector3.ZERO
	for location in desired_locations:
		location_sum += location
	
	brain.unit.set_movement_target(location_sum / desired_locations.size())
	
	brain.request_attack.emit(brain.target,brain.unit)
	
	return true

func _clean_fleeing_list(brain:BrainComponent):
	var to_remove = []
	var index = 0
	for enemy in brain.fleeing:
		if !enemy || !is_instance_valid(enemy):
			to_remove.append(index)
		index += 1
	
	for i in to_remove.size():
		brain.fleeing.remove_at(to_remove[i])

func _on_body_entered_flee_range(enemy, brain:BrainComponent):
	if !(enemy is Unit): return
	brain.fleeing.append(enemy)

func _on_body_exited_flee_range(enemy, brain:BrainComponent):
	if !(enemy is Unit): return
	brain.fleeing.remove_at(brain.fleeing.find(enemy))
