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

func _on_next_day_button_pressed():
	if _spawned_building:
		navigation_region.bake_navigation_mesh(false)
		_spawned_building = false
	_day += 1
	_spawn_wave(_day)
	on_night.emit()

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
		on_spawn_enemy.emit(UnitSpawner.UnitType.Imp)

func _on_unit_spawner_spawn_building(_building_type:UnitSpawner.BuildingType):
	_spawned_building = true
