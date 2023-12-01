extends Node

class_name GameManager

@export var flat_enemy_power_increase: int = 0

var unlocked_enemy_types: Array[UnitSpawner.UnitType] = [UnitSpawner.UnitType.Goblin]
var force_spawn_enemy_type = null

signal on_spawn_enemy(unit_type: UnitSpawner.UnitType)
signal on_spawn_enemy_group(unit_types: Array[UnitSpawner.UnitType])

@export var enemy_power_limit: int = 40

static var I: GameManager

@export_group("Observables")
@export var day_number: ObservableResource
@export var is_day: ObservableResource

var unit_ratios = {
	UnitSpawner.UnitType.Goblin: 0.5,
	UnitSpawner.UnitType.GoblinPriest: 0.1,
	UnitSpawner.UnitType.Ogre: 0.15,
	UnitSpawner.UnitType.Imp: 0.25
}
var unit_ratio_map = RatioMap.new({
	UnitSpawner.UnitType.Goblin: 0.5
})

func _ready():
	I = self
	is_day.value_changed.connect(_on_day_changed)

func _on_day_changed(is_d, _was_d):
	if is_d: return
	_spawn_wave(day_number.value)

func get_spawn_power(day):
	var cycle = ((day - GoblinCardManager.I.first_modifier_night) % GoblinCardManager.I.modifier_interval) if day > GoblinCardManager.I.first_modifier_night else 0
	cycle = (cycle / 2.0) as int
	var linear_component = 1 + day
	return clampi(linear_component+cycle, 2, enemy_power_limit) + flat_enemy_power_increase

func _spawn_wave(day):
	if day == 7: add_enemy_unit_type(UnitSpawner.UnitType.GoblinPriest)
	
	var random_component = randi_range(0,1)
	
	var spawn_power = get_spawn_power(day) + random_component
	
	var group_count = 1 if day <= 5 else (2 if day <= 15 else (3 if day < 35 else 4))
	for group_i in group_count:
		var size_of_group = 0
		if group_i == group_count - 1:
			size_of_group = spawn_power
		else:
			@warning_ignore("integer_division")
			size_of_group = spawn_power / (2 + group_i) 
		
		_spawn_group(size_of_group)
		
		spawn_power -= size_of_group

func add_enemy_unit_type(type:UnitSpawner.UnitType):
	if !unlocked_enemy_types.has(type):
		unlocked_enemy_types.append(type)
		unit_ratio_map._append(type, unit_ratios[type])
		force_spawn_enemy_type = type

func remove_enemy_unit_type(type:UnitSpawner.UnitType):
	unlocked_enemy_types = unlocked_enemy_types.filter(func(enemy_type): return enemy_type != type)

func _spawn_group(size):
	var to_spawn: Array[UnitSpawner.UnitType] = []
	for i in size:
		if force_spawn_enemy_type:
			to_spawn.append(force_spawn_enemy_type)
			force_spawn_enemy_type = null
		else:
			to_spawn.append(unlocked_enemy_types.pick_random())
	on_spawn_enemy_group.emit(to_spawn)
