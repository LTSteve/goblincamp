extends Node

class_name ThrottledProcessManager

static var time_scale: int = 1

@export var unit_moves_per_tick: int = 100
@export var max_update_msec: int = 4
@export var unit_updates_per_time_check: int = 5

@export_group("Observables")
@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource
@export var npcs_resource: ObservableResource
@export var projectiles_resource: ObservableResource

var _unit_index: int = 0

func _physics_process(delta):
	#update all npcs
	for npc in npcs_resource.value:
		if !is_instance_valid(npc): continue
		npc.do_move(delta)
	
	var player_count = players_resource.value.size()
	var enemy_count = enemies_resource.value.size()
	Global.players_minus_enemies = player_count - enemy_count
	var projectile_count = projectiles_resource.value.size()
	var total_count = player_count+enemy_count+projectile_count
	if total_count == 0: return
	
	_unit_index = _unit_index if _unit_index < total_count else 0
	var last_unit_index = _unit_index
	var num_moved = 0
	var first = true
	
	@warning_ignore("integer_division")
	var scaled_delta = delta * (1 if total_count <= unit_moves_per_tick else (total_count / unit_moves_per_tick))
	
	var starting_time = Time.get_ticks_msec()
	var ending_time = starting_time + max_update_msec
	
	while (first || _unit_index != last_unit_index) && num_moved < unit_moves_per_tick:
		first = false
		var unit
		if _unit_index < player_count:
			unit = players_resource.value[_unit_index]
		elif (_unit_index - player_count) < enemy_count:
			unit = enemies_resource.value[_unit_index - player_count]
		elif(_unit_index - player_count - enemy_count) < projectile_count:
			unit = projectiles_resource.value[_unit_index - player_count - enemy_count]
		if is_instance_valid(unit): 
			unit.do_move(scaled_delta)
			num_moved += 1
		_unit_index = (_unit_index + 1) if _unit_index < total_count else 0
		if (num_moved % unit_updates_per_time_check) == 0 && Time.get_ticks_msec() >= ending_time:
			#print("long unit move update, exiting after ", num_moved)
			break
	@warning_ignore("integer_division")
	time_scale = (total_count / num_moved) if (total_count > num_moved && num_moved > 0) else 1
