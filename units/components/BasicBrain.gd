extends Node

class_name BasicBrain

@export var unit:Unit
@export var weapon:MeleeWeapon
@export var comfortable_range_modifier:float = 0.5

signal request_attack(target:Unit,me:Unit)
signal enter_combat()
signal exit_combat()

var target:Unit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var had_no_target = !target
	
	target = Global.nearest_unit(Global.players, unit.global_position) if unit.is_enemy else Global.nearest_unit(Global.enemies, unit.global_position)
	
	if target && had_no_target:
		enter_combat.emit()
	
	if !target:
		exit_combat.emit()
		return
	
	if unit.position.distance_to(target.global_position) > weapon.range * comfortable_range_modifier:
		unit.set_movement_target(target.global_position)
	else:
		unit.set_movement_target(unit.global_position)
	
	request_attack.emit(target,unit)

