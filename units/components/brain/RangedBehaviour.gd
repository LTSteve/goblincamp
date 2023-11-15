extends Behaviour

class_name RangedBehaviour

@export var comfortable_range_modifier:float = 0.5
@export var flee_distance:float = 8
@export var flee_speed_scale: float = 0.75

@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

func initialize(brain:BrainComponent):
	brain.weapons += _bind_to_all_weapons(brain,typeof(RangedWeapon))
	return brain.weapons[0] if brain.weapons.size() else null

func assign_target(_delta, brain:BrainComponent, _weapon):
	var had_no_target = !brain.target
	
	brain.target = Global.nearest_unit(players_resource.value if brain.unit.is_enemy else enemies_resource.value, brain.unit.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target && had_no_target:
		brain.enter_combat.emit()
	
	if !brain.target:
		#brain.request_attack_rewind.emit()
		brain.exit_combat.emit()

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
	
	var fleeing = false
	for enemy in brain.fleeing:
		fleeing = true
		desired_locations.append(enemy.global_position + Math.unit_v3(brain.unit.global_position - enemy.global_position) * flee_distance)
	
	var location_sum = Vector3.ZERO
	for location in desired_locations:
		location_sum += location
	
	brain.unit.set_movement_target(location_sum / desired_locations.size(), flee_speed_scale if fleeing else 1.0)
	
	brain.request_attack.emit(brain.target,brain.unit)
	
	return true
