extends Node

class_name GameManager

@export var sigmoid_offset: float = -10
@export var sigmoid_x_scale: float = 0.5
@export var sigmoid_y_scale: float = 10
@export var linear_offset: float = 2
@export var linear_scale: float = 2

@export var navigation_region: NavigationRegion3D

@export var flat_enemy_power_increase: int = 0

@export_dir var enemy_spawn_folder: String = "res://enemy_spawns"
var enemy_spawns: Array[EnemySpawnResource] = []

var unlocked_enemy_types: Array[UnitSpawner.UnitType] = [UnitSpawner.UnitType.Goblin]
var force_spawn_enemy_type = null

signal on_spawn_enemy(unit_type: UnitSpawner.UnitType)
signal on_spawn_enemy_group(enemy_spawn: EnemySpawnResource)

signal on_night(day:int)
signal on_day()
signal on_game_over()

var _day:int = 0
var _spawned_building:bool = false

static var I: GameManager

func game_over():
	Wait.timer(2, self, func():
		if Global.players.size() == 0 && Global.enemies.size() != 0:
			on_game_over.emit()
	)

func cycle_to_day():
	on_day.emit()

func _ready():
	I = self
	var directory = DirAccess.open(enemy_spawn_folder)
	var files = directory.get_files()
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		var resource = load(enemy_spawn_folder + "/" + file)
		if !(resource is EnemySpawnResource): continue
		enemy_spawns.append(resource)

@export var unit_moves_per_tick: int = 100
@export var max_update_msec: int = 4
@export var unit_updates_per_time_check: int = 5
@export var enemy_power_limit: int = 40
var _unit_index: int = 0

static var time_scale: int = 1

func on_free():
	Global.players = []
	Global.enemies = []
	Global.projectiles = []

func _physics_process(delta):
	var player_count = Global.players.size()
	var enemy_count = Global.enemies.size()
	Global.players_minus_enemies = player_count - enemy_count
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
	time_scale = (total_count / num_moved) if (total_count > num_moved && num_moved > 0) else 1


func _on_next_day_button_pressed():
	TodoList.new(
	[func(todo_list:TodoList):
		if _spawned_building:
			navigation_region.bake_navigation_mesh(true)
			todo_list.finish_step_after_signal(navigation_region.bake_finished)
		else:
			todo_list.mark_step_done()
	,GoblinCardPanel.I.try_open.bind(_day+1)
	], true).on_done(_start_next_day)

func _start_next_day():
	_spawned_building = false
	_day += 1
	on_night.emit(_day)

#linked from on_night
func _spawn_wave(day: int):
	var cycle = (day - GoblinCardPanel.I.first_modifier_night) % GoblinCardPanel.I.modifier_interval
	
	if day == 7: unlocked_enemy_types.append(UnitSpawner.UnitType.GoblinPriest)
	
	var random_component = randi_range(0,1)
	var linear_component = floor(day * 0.5)
	
	var spawn_power = clampi(random_component+linear_component+cycle, 1, enemy_power_limit) + flat_enemy_power_increase
	
	var available_enemy_spawns = enemy_spawns.filter(
	func(es): 
		return es.enemies.all(
		func(enemy):
			return unlocked_enemy_types.has(enemy)
		)
	)
	
	var enemy_spawns_by_pwr = [
		[],
		available_enemy_spawns.filter(func(es): return es.level <= 1),
		available_enemy_spawns.filter(func(es): return es.level == 2),
		available_enemy_spawns.filter(func(es): return es.level == 3),
		available_enemy_spawns.filter(func(es): return es.level >= 4)
	]
	
	var spawns: Array[EnemySpawnResource] = []
	
	if force_spawn_enemy_type != null:
		var available_forced_enemies = available_enemy_spawns.filter(func(es): return es.enemies.has(force_spawn_enemy_type))
		available_forced_enemies.sort_custom(func(es1, es2):
			return es1.level < es2.level
		)
		var force_spawn = available_forced_enemies[0]
		spawns.append(force_spawn)
		force_spawn_enemy_type = null
		spawn_power -= force_spawn.level
	
	while spawn_power > 0:
		enemy_spawns.shuffle()
		var pwr = randi_range(1, min(spawn_power, 4))
		var spawns_by_pwr = enemy_spawns_by_pwr[pwr]
		spawns.append(spawns_by_pwr[randi_range(0,spawns_by_pwr.size() - 1)])
		spawn_power -= pwr
	
	for spawn in spawns:
		on_spawn_enemy_group.emit(spawn)

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
	on_night.emit(_day)
	if navigation_region.bake_finished.is_connected(_start_next_day):
		navigation_region.bake_finished.disconnect(_start_next_day)
