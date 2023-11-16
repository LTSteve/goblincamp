@tool

extends Node

@export var clear: bool:
	set(_value):
		clear = false
		_clear()

@export var re_render: bool:
	set(_value):
		re_render = false
		_on_data_changed(scatter_setting.current_value if !Engine.is_editor_hint() else 1)

@export var ground: Ground
@export var scatter_holder: Node3D

@export var max_scatter_count: int = 1000
@export var rock_ratio: float = .1
@export var scatter_min: float = 0.1
@export var scatter_max: float = 0.99
@export var scatter_setting: SettingResource
@export var scatter_scale: Vector3 = Vector3.ONE

@export var rock_material: Material
@export var grass_material: Material

var grass_meshes: Array[Mesh] = []
var grass_multimeshes: Array[MultiMeshInstance3D] = []
var grass_count: int
var rock_meshes: Array[Mesh] = []
var rock_multimeshes: Array[MultiMeshInstance3D] = []
var rock_count: int

var scatter_multimesh_scene: PackedScene

func _ready():
	_load_data()
	call_deferred("_post_ready")

func _post_ready():
	if !Engine.is_editor_hint():
		scatter_setting.on_change.connect(_on_data_changed)
	_on_data_changed(scatter_setting.current_value if !Engine.is_editor_hint() else 1)

func _clear():
	for s in scatter_holder.get_children():
		if Engine.is_editor_hint():
			if is_instance_valid(s):
				s.free()
		else:
			if is_instance_valid(s):
				s.queue_free()

func _on_data_changed(scatter_value):
	_clear()
	
	if rock_meshes.size() == 0:
		_load_data()
	
	var current_scatter_count = max_scatter_count * scatter_value
	rock_count = (current_scatter_count * rock_ratio / 3) as int
	grass_count = (current_scatter_count * (1.0 - rock_ratio) / 2) as int
	
	_update_multi_meshes()
	
	for i in rock_count:
		_spawn_scatter(rock_multimeshes[0], i)
		_spawn_scatter(rock_multimeshes[1], i)
		_spawn_scatter(rock_multimeshes[2], i)
	for i in grass_count:
		_spawn_scatter(grass_multimeshes[0], i)
		_spawn_scatter(grass_multimeshes[1], i)

func _load_data():
	if DB.I && DB.I.scenes && DB.I.scenes.has("rock1_scene"):
		#load from DB
		rock_meshes = [
			DB.I.scenes.rock1_mesh,
			DB.I.scenes.rock2_mesh,
			DB.I.scenes.rock3_mesh
		]
		grass_meshes = [
			DB.I.scenes.grass1_mesh,
			DB.I.scenes.grass2_mesh
		]
		scatter_multimesh_scene = DB.I.scenes.scatter_multimesh_scene
	else:
		rock_meshes = [
			load("res://models/rocks/rock1_Cube.res"),
			load("res://models/rocks/rock2_Cube_001.res"),
			load("res://models/rocks/rock3_Cube_002.res")
		]
		grass_meshes = [
			load("res://models/grass/grass1_Plane_001.res"),
			load("res://models/grass/grass2_Plane_003.res")
		]
		scatter_multimesh_scene = load("res://ground_generation/scatter_multimesh.tscn")

func _update_multi_meshes():
	#spawn multimeshes
	rock_multimeshes = []
	grass_multimeshes = []
	
	
	for mesh in rock_meshes:
		var new_mm = scatter_multimesh_scene.instantiate() as MultiMeshInstance3D
		
		new_mm.multimesh = MultiMesh.new()
		new_mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		new_mm.multimesh.mesh = mesh
		new_mm.material_override = rock_material
		new_mm.multimesh.instance_count = rock_count
		
		rock_multimeshes.append(new_mm)
		scatter_holder.add_child(new_mm)
	
	for mesh in grass_meshes:
		var new_mm = scatter_multimesh_scene.instantiate() as MultiMeshInstance3D
		
		new_mm.multimesh = MultiMesh.new()
		new_mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		new_mm.multimesh.mesh = mesh
		new_mm.material_override = grass_material
		new_mm.multimesh.instance_count = grass_count
		
		grass_multimeshes.append(new_mm)
		scatter_holder.add_child(new_mm)

func _spawn_scatter(multimesh_instance: MultiMeshInstance3D, mm_i: int):
	var rand_v2 = Math.rand_v2_range(scatter_min, scatter_max)
	var rand_x = rand_v2.x * ground.scale.x
	var rand_y = rand_v2.y * ground.scale.z
	var rand_rot = Math.random_rotation()
	var rand_scale = randf_range(0.93,1.07)

	var ground_height = Ground.sample_height(rand_x,rand_y)

	var random_transform = Transform3D.IDENTITY
	random_transform = random_transform.rotated(Vector3.UP, rand_rot)
	random_transform = random_transform.scaled(scatter_scale * rand_scale)
	random_transform = random_transform.translated(Vector3(rand_x, ground_height, rand_y))
	
	multimesh_instance.multimesh.set_instance_transform(mm_i, random_transform)
