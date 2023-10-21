extends Node

class_name UnitSpawner

signal on_spawn_building(building_type:BuildingType)

enum UnitType {Knight=0, Witch, Woodsman, Goblin, Imp, Ogre}
enum BuildingType {Blacksmith=0, Leatherworker, Enchanter}

@onready var knight_scene = preload("res://units/knight.tscn")
@onready var witch_scene = preload("res://units/witch.tscn")
@onready var woodsman_scene = preload("res://units/woodsman.tscn")

@onready var goblin_scene = preload("res://units/goblin.tscn")
@onready var ogre_scene = preload("res://units/ogre.tscn")
@onready var imp_scene = preload("res://units/imp.tscn")

@onready var blacksmith_scene = preload("res://buildings/blacksmith.tscn")
@onready var leatherworker_scene = preload("res://buildings/leatherworker.tscn")
@onready var enchanter_scene = preload("res://buildings/enchanter.tscn")

@export var units_folder: Node
@export var buildings_folder: Node
@export var world_root: Node3D

@export var friendly_spawn_center: Vector3 = Vector3.ZERO
@export var friendly_spawn_radius: float = 10.0

@export var enemy_spawn_center: Vector3 = Vector3.ZERO
@export var enemy_spawn_min_radius: float = 15.0
@export var enemy_spawn_max_radius: float = 50.0

@export var building_spawn_center: Vector3 = Vector3.ZERO
@export var building_spawn_radius: float = 5
@export var min_building_radius: float = 10
@export var max_building_radius: float = 50

static var I: UnitSpawner

func _ready():
	I = self

func spawn_friendly(unit_type: UnitType):
	var r_v2 = Math.rand_v2_range(0, friendly_spawn_radius)
	_spawn(unit_type, friendly_spawn_center + Math.v2_to_v3(r_v2))

func spawn_hostile(unit_type: UnitType, point: Vector2 = Vector2.ZERO):
	if point == Vector2.ZERO:
		point = Math.rand_v2_range(enemy_spawn_min_radius, enemy_spawn_max_radius)
	_spawn(unit_type, enemy_spawn_center + Math.v2_to_v3(point))

func spawn_enemy_group(enemy_spawn: EnemySpawnResource):
	var r_v2 = Math.rand_v2_range(enemy_spawn_min_radius, enemy_spawn_max_radius)
	for enemy in enemy_spawn.enemies:
		spawn_hostile(enemy, r_v2 + Math.rand_v2_range(0.1, 2))

func spawn_building(building_type: BuildingType, value: int, resource: CardResource):
	
	var space_state = world_root.get_world_3d().direct_space_state
	var sphere:SphereShape3D = SphereShape3D.new()
	sphere.radius = building_spawn_radius
	
	var physics_sphere = PhysicsShapeQueryParameters3D.new()
	physics_sphere.shape = sphere
	physics_sphere.collision_mask = 0b1100 # trees and buildings
	
	for check_radius in range(building_spawn_radius, max_building_radius, building_spawn_radius):
		var starting_rotation = Math.random_rotation()
		for check_rotation in Math.rangef(starting_rotation, deg_to_rad(359.99) + starting_rotation, _linear_distance_to_rotation(building_spawn_radius, check_radius)):
			var check_position = building_spawn_center + Math.v2_to_v3(Vector2.RIGHT.rotated(check_rotation) * check_radius, 0)
			physics_sphere.transform = world_root.transform.translated(check_position)
			var intersections = space_state.intersect_shape(physics_sphere,1)
			if !intersections || intersections.size() == 0:
				var instance = _get_building_scene(building_type).instantiate() as Node3D
				instance.value = value
				instance.card_resource = resource
				buildings_folder.add_child(instance)
				instance.global_position = check_position
				instance.rotate_y(Math.random_rotation())
				on_spawn_building.emit(building_type)
				return

func _linear_distance_to_rotation(distance:float, radius: float):
	var a:Vector2 = Vector2.RIGHT * radius
	var p0 = Vector2.LEFT * radius
	if a.distance_to(p0) < distance: return deg_to_rad(360)
	
	var qa = 1
	var qb = -1
	var qc = -(distance * distance) / (2 * radius * radius)
	var cos_angle = _closest_to_zero((-qb + sqrt(qb*qb - 4 * qa * qc))/(2 * qa),(-qb - sqrt(qb*qb - 4 * qa * qc))/(2 * qa))
	var result = acos(cos_angle)
	return result

func _closest_to_zero(val1:float, val2:float):
	if absf(val1) > absf(val2):
		return val2
	return val1

func _spawn(unit_type: UnitType, position: Vector3):
	var iterations = 3 if unit_type == UnitType.Imp else 1
	for i in iterations:
		var instance: Unit = _get_unit_scene(unit_type).instantiate()
		units_folder.add_child(instance)
		
		instance.position = position
		position += Vector3((randf()-0.5)*2, 0, (randf()-0.5)*2)

func _get_unit_scene(unit_type: UnitType) -> PackedScene:
	match unit_type:
		UnitType.Knight:
			return knight_scene
		UnitType.Witch:
			return witch_scene
		UnitType.Woodsman:
			return woodsman_scene
		UnitType.Goblin:
			return goblin_scene
		UnitType.Imp:
			return imp_scene
		UnitType.Ogre:
			return ogre_scene
	
	return null

func _get_building_scene(building_type: BuildingType) -> PackedScene:
	match building_type:
		BuildingType.Blacksmith:
			return blacksmith_scene
		BuildingType.Leatherworker:
			return leatherworker_scene
		BuildingType.Enchanter:
			return enchanter_scene
	
	return null
