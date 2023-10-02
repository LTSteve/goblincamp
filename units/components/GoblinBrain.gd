extends Node

class_name GoblinBrain

@export var unit:Unit

signal request_attack(target:Unit,me:Unit)
signal enter_combat()
signal exit_combat()

var target:Unit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var had_no_target = !target
	
	target = Global.nearest_unit(Global.players, unit.global_position)
	
	if target && had_no_target:
		enter_combat.emit()
	
	if !target:
		exit_combat.emit()
		return
	
	unit.set_movement_target(target.global_position)
	request_attack.emit(target,unit)
