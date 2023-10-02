extends Node

class_name UnitSpawner

enum UnitType {Knight=0, Witch, Huntsman, Goblin, Imp, Ogre}

@onready var knight_scene = preload("res://units/knight.tscn")
@onready var goblin_scene = preload("res://units/goblin.tscn")
@onready var ogre_scene = preload("res://units/ogre.tscn")

@export var units_folder: Node

@export var friendly_spawn_center: Vector3 = Vector3.ZERO
@export var friendly_spawn_radius: float = 10.0

@export var enemy_spawn_center: Vector3 = Vector3.ZERO
@export var enemy_spawn_min_radius: float = 15.0
@export var enemy_spawn_max_radius: float = 50.0

func spawn_friendly(unit_type: UnitType):
	var angle = deg_to_rad(randf() * 359.9)
	var distance = friendly_spawn_radius * randf()
	_spawn(unit_type, friendly_spawn_center + Quaternion.from_euler(Vector3(0,angle,0)) * Vector3.BACK * distance)

func spawn_hostile(unit_type: UnitType):
	var angle = deg_to_rad(randf() * 359.9)
	var distance = enemy_spawn_min_radius + (enemy_spawn_max_radius - enemy_spawn_min_radius) * randf()
	_spawn(unit_type, enemy_spawn_center + Quaternion.from_euler(Vector3(0,angle,0)) * Vector3.BACK * distance)

func _spawn(unit_type: UnitType, position: Vector3):
	var instance: Unit = _get_unit_scene(unit_type).instantiate()
	units_folder.add_child(instance)
	
	instance.position = position

func _get_unit_scene(unit_type: UnitType) -> PackedScene:
	match unit_type:
		UnitType.Knight:
			return knight_scene
		UnitType.Witch:
			return knight_scene
		UnitType.Huntsman:
			return knight_scene
		UnitType.Goblin:
			return goblin_scene
		UnitType.Imp:
			return goblin_scene
		UnitType.Ogre:
			return ogre_scene
	
	return null
