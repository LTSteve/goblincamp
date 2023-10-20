extends Node

class_name GameManager

@export var sigmoid_offset: float = -10
@export var sigmoid_x_scale: float = 0.5
@export var sigmoid_y_scale: float = 10
@export var linear_offset: float = 2
@export var linear_scale: float = 2

@export var navigation_region: NavigationRegion3D

@export var ogre_cost: float = 15
@export var imp_cost: float = 3
@export var goblin_cost: float = 2

signal on_spawn_enemy(unit_type: UnitSpawner.UnitType)

signal on_night()
signal on_day()

var _day:int = 0
var _spawned_building:bool = false

static var I: GameManager

func cycle_to_day():
	on_day.emit()

func _ready():
	I = self

@export var unit_moves_per_tick: int = 100
@export var max_update_msec: int = 4
@export var unit_updates_per_time_check: int = 5
var _unit_index: int = 0

static var time_scale: int = 1

func _physics_process(delta):
	var player_count = Global.players.size()
	var enemy_count = Global.enemies.size()
	var projectile_count = Global.projectiles.size()
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
			unit = Global.players[_unit_index]
		elif (_unit_index - player_count) < enemy_count:
			unit = Global.enemies[_unit_index - player_count]
		elif(_unit_index - player_count - enemy_count) < projectile_count:
			unit = Global.projectiles[_unit_index - player_count - enemy_count]
		if is_instance_valid(unit): 
			unit.do_move(scaled_delta)
			num_moved += 1
		_unit_index = (_unit_index + 1) if _unit_index < total_count else 0
		if (num_moved % unit_updates_per_time_check) == 0 && Time.get_ticks_msec() >= ending_time:
			#print("long unit move update, exiting after ", num_moved)
			break
	@warning_ignore("integer_division")
	time_scale = (total_count / num_moved) if total_count > num_moved else 1


func _on_next_day_button_pressed():
	if _spawned_building:
		navigation_region.bake_navigation_mesh(true)
		navigation_region.bake_finished.connect(_start_next_day)
	else:
		_start_next_day()

func _start_next_day():
	_spawned_building = false
	_day += 1
	_spawn_wave(_day)
	on_night.emit()
	if navigation_region.bake_finished.is_connected(_start_next_day):
		navigation_region.bake_finished.disconnect(_start_next_day)

func _spawn_wave(number: float):
	
	var random_component: float = 0
	if number >= 10 && number < 20:
		random_component = randf_range(0,(number-10)+1)
	elif number >= 20:
		random_component = randf_range(0, 11)
	
	var exponential_component: float = number * number / 2.0
	if number < 20:
		exponential_component = number * number / 2.0
	else:
		exponential_component = 200
	
	var linear_component: float = number * linear_scale + linear_offset
	
	var spawn_power: float = linear_component + exponential_component + random_component
	
	var ogre_count: int = 0
	var goblin_count: int = 0
	var imp_count: int = 0
	
	if number > 15:
		var max_ogre = (spawn_power/ogre_cost) as int
		@warning_ignore("integer_division")
		var min_ogre = clampi((max_ogre / 2) as int, 1, max_ogre)
		ogre_count = randi_range(min_ogre, max_ogre)
		spawn_power -= ogre_count * ogre_cost
	
	if number < 5:
		goblin_count = (spawn_power / goblin_cost) as int
		spawn_power -= goblin_count * goblin_cost
	else:
		imp_count = ((spawn_power / imp_cost))/2 as int
		spawn_power -= imp_count * imp_cost
		goblin_count = (spawn_power / goblin_cost) as int
		spawn_power -= goblin_count * goblin_cost
	
	goblin_count = clampi(goblin_count, 1, goblin_count)
	
	for i in ogre_count:
		on_spawn_enemy.emit(UnitSpawner.UnitType.Ogre)
	
	for i in imp_count:
		on_spawn_enemy.emit(UnitSpawner.UnitType.Imp)
	
	for i in goblin_count:
		on_spawn_enemy.emit(UnitSpawner.UnitType.Goblin)

func _on_unit_spawner_spawn_building(_building_type:UnitSpawner.BuildingType):
	_spawned_building = true


func _on_stress_test_button_pressed():
	for i in 100:
		UnitSpawner.I.spawn_friendly(UnitSpawner.UnitType.Knight)
	for i in 100:
		UnitSpawner.I.spawn_friendly(UnitSpawner.UnitType.Witch)
	for i in 100:
		UnitSpawner.I.spawn_friendly(UnitSpawner.UnitType.Woodsman)
	
	_spawn_wave(20)
	
	_spawned_building = false
	_day += 1
	on_night.emit()
	if navigation_region.bake_finished.is_connected(_start_next_day):
		navigation_region.bake_finished.disconnect(_start_next_day)
