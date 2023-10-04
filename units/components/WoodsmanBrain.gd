extends Node

class_name WoodsmanBrain


@export var unit:Unit
@export var comfortable_range_modifier:float = 0.8
@export var flee_distance:float = 8
@export var melee_weapon:MeleeWeapon
@export var ranged_weapon:RangedWeapon
@export var min_nearby_melee_threshold = 1
@export var max_nearby_melee_threshold = 3
@export var mode_switch_limit = 5 #throttle for weapon switching (s)

signal request_attack(target:Unit,me:Unit)
signal switch_melee(melee:bool)
signal enter_combat()
signal exit_combat()
signal on_lock_target(target:Unit)

var target:Unit

var _nearby:Array[Unit] = []
var _mode_switch_cooldown:float = 0
var _melee:bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var had_no_target = !target
	_mode_switch_cooldown -= delta
	
	target = Global.nearest_unit(Global.enemies, unit.global_position)
	
	on_lock_target.emit(target)
	
	if target && had_no_target:
		enter_combat.emit()
	
	if !target:
		exit_combat.emit()
		return

	_clean_nearby_list()

	# throttle mode switches so the unit doesn't get stuck swapping back and forth
	if _mode_switch_cooldown <= 0:
		var new_melee = _nearby.size() > min_nearby_melee_threshold && _nearby.size() <= max_nearby_melee_threshold
		if new_melee != _melee:
			_melee = new_melee
			_mode_switch_cooldown = mode_switch_limit
			switch_melee.emit(_melee)
	
	if _melee:
		_melee_logic()
	else:
		_ranged_logic()

func _melee_logic():
	if unit.position.distance_to(target.global_position) > melee_weapon.range * comfortable_range_modifier:
		unit.set_movement_target(target.global_position)
	else:
		unit.set_movement_target(unit.global_position)
	
	request_attack.emit(target,unit)

func _ranged_logic():
	var target_separation = target.global_position - unit.global_position
	var distance_to_target = target_separation.length()
	
	var desired_locations = []
	
	if distance_to_target > ranged_weapon.range * comfortable_range_modifier:
		desired_locations.append(target.global_position)
	else:
		desired_locations.append(unit.global_position)
	
	for enemy in _nearby:
		desired_locations.append(Math.unit(unit.global_position - target_separation) * flee_distance)
	
	var location_sum = Vector3.ZERO
	for location in desired_locations:
		location_sum += location
	
	unit.set_movement_target(location_sum / desired_locations.size())
	
	request_attack.emit(target,unit)

func _clean_nearby_list():
	var to_remove = []
	var index = 0
	for enemy in _nearby:
		if !enemy || !is_instance_valid(enemy):
			to_remove.append(index)
		index += 1
	
	for i in to_remove.size():
		_nearby.remove_at(to_remove[i])

func _on_body_entered_nearby_range(enemy):
	if !(enemy is Unit): return
	_nearby.append(enemy)

func _on_body_exited_nearby_range(enemy):
	if !(enemy is Unit): return
	if !_nearby.has(enemy): return
	_nearby.remove_at(_nearby.find(enemy))
