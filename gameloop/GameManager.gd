extends Node

class_name GameManager

@export var sigmoid_offset: float = -10
@export var sigmoid_x_scale: float = 0.5
@export var sigmoid_y_scale: float = 10
@export var linear_offset: float = 2
@export var linear_scale: float = 2

@export var flat_enemy_power_increase: int = 0

var enemy_spawns = []

var unlocked_enemy_types: Array[UnitSpawner.UnitType] = [UnitSpawner.UnitType.Goblin]
var force_spawn_enemy_type = null

signal on_spawn_enemy(unit_type: UnitSpawner.UnitType)
signal on_spawn_enemy_group(enemy_spawn: EnemySpawnResource)

signal on_game_over()

@export var enemy_power_limit: int = 40

static var I: GameManager

@export_group("Observables")
@export var day_number: ObservableResource
@export var is_day: ObservableResource
@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

func _ready():
	I = self
	is_day.value_changed.connect(_on_day_changed)
	players_resource.value_changed.connect(_on_players_changed)

func _on_players_changed(players,_old_players):
	if players.size() == 0:
		game_over()

func game_over():
	Wait.timer(2, self, func():
		if players_resource.value.size() == 0 && enemies_resource.value.size() != 0:
			on_game_over.emit()
	)

func _on_day_changed(is_d, _was_d):
	if is_d: return
	_spawn_wave(day_number.value)

func _spawn_wave(day):
	var cycle = (day - GoblinCardPanel.I.first_modifier_night) % GoblinCardPanel.I.modifier_interval
	
	if day == 7: unlocked_enemy_types.append(UnitSpawner.UnitType.GoblinPriest)
	
	var random_component = randi_range(0,1)
	var linear_component = floor(day * 0.5)
	
	var spawn_power = clampi(random_component+linear_component+cycle, 1, enemy_power_limit) + flat_enemy_power_increase
	
	enemy_spawns = DB.I.resource_groups["enemy_spawns"]
	
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
