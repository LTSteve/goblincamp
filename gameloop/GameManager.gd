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
signal on_spawn_enemy_group(unit_types: Array[UnitSpawner.UnitType])

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
	
	var spawn_power = clampi(random_component+linear_component+cycle, 2, enemy_power_limit) + flat_enemy_power_increase
	
	var group_count = 1 if day <= 5 else (2 if day <= 15 else (3 if day < 35 else 4))
	for group_i in group_count:
		var size_of_group = 0
		if group_i == group_count - 1:
			size_of_group = spawn_power
		else:
			size_of_group = spawn_power / (2 + group_i) 
		
		_spawn_group(size_of_group)
		
		spawn_power -= size_of_group

func _spawn_group(size):
	var to_spawn: Array[UnitSpawner.UnitType] = []
	for i in size:
		to_spawn.append(unlocked_enemy_types.pick_random())
	on_spawn_enemy_group.emit(to_spawn)
