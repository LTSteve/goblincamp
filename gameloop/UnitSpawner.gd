extends Node

class_name UnitSpawner

signal on_spawn_unit(unit:Unit)

enum UnitType {Knight=0, Witch, Woodsman, Bearkin, Goblin, Imp, Ogre, GoblinPriest}
enum BuildingType {Blacksmith=0, Leatherworker, Enchanter, Tavern}

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

@export var day_number_resource: ObservableResource

var double_imps: bool = false

static var I: UnitSpawner

func _ready():
	I = self

func spawn_friendly(unit_type: UnitType):
	var r_v2 = Math.rand_v2_range(0, friendly_spawn_radius)
	_spawn(unit_type, friendly_spawn_center + Math.v2_to_v3(r_v2))

func spawn_hostile(unit_type: UnitType, point: Vector2 = Vector2.ZERO):
	if point == Vector2.ZERO:
		point = _get_enemy_spawn_point()
	_spawn(unit_type, enemy_spawn_center + Math.v2_to_v3(point))
	if double_imps && unit_type == UnitType.Imp:
		_spawn(unit_type, enemy_spawn_center + Math.v2_to_v3(point+Vector2.RIGHT))

func spawn_hostile_group(unit_types: Array[UnitType]):
	var point = _get_enemy_spawn_point()
	for unit_type in unit_types:
		spawn_hostile(unit_type, point)

func _get_enemy_spawn_point():
	var actual_enemy_min = enemy_spawn_min_radius
	var actual_enemy_max = enemy_spawn_max_radius
	var day = day_number_resource.value
	
	if day <= 5:
		actual_enemy_max *= 0.5
	elif day <= 20:
		actual_enemy_max *= 0.75
	else:
		actual_enemy_min = actual_enemy_max * 0.5
	
	return Math.rand_v2_range(actual_enemy_min, actual_enemy_max)

func spawn_building(building_type: BuildingType, selected_card: CardResource, all_cards: Array[CardResource]):
	
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
				var instance = _get_building_scene(building_type).instantiate() as Building
				instance.all_cards = all_cards
				instance.select_card(selected_card)
				buildings_folder.add_child(instance)
				instance.global_position = check_position
				instance.rotate_y(Math.random_rotation())
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
		on_spawn_unit.emit(instance)

func _get_unit_scene(unit_type: UnitType) -> PackedScene:
	match unit_type:
		UnitType.Knight:
			return DB.I.scenes.knight_scene
		UnitType.Witch:
			return DB.I.scenes.witch_scene
		UnitType.Woodsman:
			return DB.I.scenes.woodsman_scene
		UnitType.Bearkin:
			return DB.I.scenes.bearkin_scene
		UnitType.Goblin:
			return DB.I.scenes.goblin_scene
		UnitType.Imp:
			return DB.I.scenes.imp_scene
		UnitType.Ogre:
			return DB.I.scenes.ogre_scene
		UnitType.GoblinPriest:
			return DB.I.scenes.goblin_priest_scene
	
	return null

func _get_building_scene(building_type: BuildingType) -> PackedScene:
	match building_type:
		BuildingType.Blacksmith:
			return DB.I.scenes.blacksmith_scene
		BuildingType.Leatherworker:
			return DB.I.scenes.leatherworker_scene
		BuildingType.Enchanter:
			return DB.I.scenes.enchanter_scene
		BuildingType.Tavern:
			return DB.I.scenes.tavern_scene
	
	return null
