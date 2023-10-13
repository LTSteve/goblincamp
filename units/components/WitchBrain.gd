extends Node

class_name WitchBrain

@export var unit:Unit
@export var comfortable_range_modifier:float = 0.8
@export var flee_distance:float = 8
@export var weapon:RangedWeapon

signal request_attack(target:Unit,me:Unit)
signal enter_combat()
signal exit_combat()
signal on_lock_target(target:Unit)

var target:Unit

var _fleeing:Array[Unit] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var had_no_target = !target
	
	target = Global.nearest_unit(Global.enemies, unit.global_position)
	
	on_lock_target.emit(target)
	
	if target && had_no_target:
		enter_combat.emit()
	
	if !target:
		exit_combat.emit()
		return
	
	_clean_fleeing_list()
	
	var target_separation = target.global_position - unit.global_position
	var distance_to_target = target_separation.length()
	
	var desired_locations = []
	
	if distance_to_target > weapon.weapon_range * comfortable_range_modifier:
		desired_locations.append(target.global_position)
	else:
		desired_locations.append(unit.global_position)
	
	for enemy in _fleeing:
		desired_locations.append(Math.unit(2 * unit.global_position - enemy.global_position) * flee_distance)
	
	var location_sum = Vector3.ZERO
	for location in desired_locations:
		location_sum += location
	
	unit.set_movement_target(location_sum / desired_locations.size())
	
	request_attack.emit(target,unit)

func _clean_fleeing_list():
	var to_remove = []
	var index = 0
	for enemy in _fleeing:
		if !enemy || !is_instance_valid(enemy):
			to_remove.append(index)
		index += 1
	
	for i in to_remove.size():
		_fleeing.remove_at(to_remove[i])

func _on_body_entered_flee_range(enemy):
	if !(enemy is Unit): return
	if !_fleeing.has(enemy): return
	_fleeing.append(enemy)

func _on_body_exited_flee_range(enemy):
	if !(enemy is Unit): return
	if !_fleeing.has(enemy): return
	_fleeing.remove_at(_fleeing.find(enemy))
