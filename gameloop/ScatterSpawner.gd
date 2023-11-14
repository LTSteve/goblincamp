extends Node

static var scatters = []

@export var ground: Ground

@export var max_scatter_count: int = 1000
@export var rock_ratio: float = .1
@export var scatter_min: float = 0.1
@export var scatter_max: float = 0.99
@export var scatter_setting: SettingResource

var rocks: Array[PackedScene] = []
var grass: Array[PackedScene] = []

func _ready():
	_load_data()
	call_deferred("_post_ready")

func _post_ready():
	scatter_setting.on_change.connect(_on_data_changed)
	_on_data_changed(scatter_setting.current_value)

func _on_data_changed(scatter_value):
	for s in scatters:
		if is_instance_valid(s):
			s.queue_free()

	if rocks.size() == 0:
		_load_data()
	
	var current_scatter_count = max_scatter_count * scatter_value
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
		var rand_scale = randf_range(0.93,1.07)
		var new_scatter: Node3D = scatter.pick_random().instantiate()
		get_tree().root.add_child(new_scatter)
		new_scatter.global_position.x = rand_x
		new_scatter.global_position.z = rand_y
		new_scatter.global_rotation.y = rand_rot
		var model = new_scatter.find_child("model") as HeightComponent
		model.scale = model.scale * rand_scale
		
		scatters.append(new_scatter)
