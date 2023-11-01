@tool

extends Node

static var scatters = []

@export var re_render: bool:
	set(_value):
		re_render = false
		_on_data_changed()

@export var ground: Ground

@export var max_scatter_count: int = 1000
@export var rock_ratio: float = .1
@export var scatter_min: float = 0.1
@export var scatter_max: float = 0.99
@export var scatter_setting: SettingResource

var rocks: Array[PackedScene] = []
var grass: Array[PackedScene] = []

var _last_scatter_setting: float = 0.5

func _ready():
	call_deferred("_on_data_changed")
	_load_data()

func _process(_delta):
	if Engine.is_editor_hint() || !scatter_setting || _last_scatter_setting == scatter_setting.value: return
	_on_data_changed()
	_last_scatter_setting = scatter_setting.value

func _on_data_changed():
	for s in scatters:
		if Engine.is_editor_hint():
			s.free()
		else:
			if is_instance_valid(s):
				s.queue_free()

	if rocks.size() == 0:
		_load_data()
	
	_last_scatter_setting = scatter_setting.value if (!Engine.is_editor_hint() && scatter_setting) else _last_scatter_setting
	var current_scatter_count = max_scatter_count * scatter_setting.value if (!Engine.is_editor_hint() && scatter_setting) else max_scatter_count
	var rock_count = current_scatter_count * rock_ratio
	var grass_count = current_scatter_count * (1.0 - rock_ratio)
	
	for i in rock_count:
		_spawn_scatter(rocks)
	for i in grass_count:
		_spawn_scatter(grass)

func _load_data():
	if DB.I && DB.I.scenes && DB.I.scenes.has("rock1_scene"):
		#load from DB
		rocks = [
			DB.I.scenes.rock1_scene,
			DB.I.scenes.rock2_scene,
			DB.I.scenes.rock3_scene
		]
		grass = [
			DB.I.scenes.grass1_scene,
			DB.I.scenes.grass2_scene
		]
	else:
		print("loading scatter from scenes")
		rocks = [
			load("res://ground_generation/scatter/Rock1.tscn"),
			load("res://ground_generation/scatter/Rock2.tscn"),
			load("res://ground_generation/scatter/Rock3.tscn")
		]
		grass = [
			load("res://ground_generation/scatter/Grass1.tscn"),
			load("res://ground_generation/scatter/Grass2.tscn")
		]

func _spawn_scatter(scatter):
		var rand_x = (1 if randf() > 0.5 else -1) * randf_range(scatter_min, scatter_max) * ground.scale.x
		var rand_y = (1 if randf() > 0.5 else -1) * randf_range(scatter_min, scatter_max) * ground.scale.z
		var rand_rot = deg_to_rad(randf_range(0, 359.99))
		var rand_height = randf_range(-0.1,0.1)
		var rand_scale = randf_range(0.93,1.07)
		var new_scatter: Node3D = scatter.pick_random().instantiate()
		get_tree().root.add_child(new_scatter)
		new_scatter.global_position.x = rand_x
		new_scatter.global_position.z = rand_y
		new_scatter.global_rotation.y = rand_rot
		var model = new_scatter.find_child("model") as HeightComponent
		model.offset += rand_height
		model.scale = model.scale * rand_scale
		
		scatters.append(new_scatter)
