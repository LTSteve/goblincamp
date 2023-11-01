@tool

extends Node

class_name TreeSpawner

@export var re_render: bool:
	set(_value):
		re_render = false
		_on_data_changed()

@export var ground: Ground
@export var navigation_region: NavigationRegion3D
@export var obsticle_folder: Node3D

@export var tree_count: int = 100
@export var tree_min: float = 0.1
@export var tree_max: float = 0.99

var trees: Array[PackedScene] = []

func _ready():
	call_deferred("_on_data_changed")
	_load_data()

func _load_data():
	if DB.I && DB.I.scenes && DB.I.scenes.has("tree1_scene"):
		#load from DB
		trees = [
			DB.I.scenes.tree1_scene,
			DB.I.scenes.tree2_scene,
			DB.I.scenes.tree3_scene,
			DB.I.scenes.tree4_scene
		]
	else:
		print("loading trees from scenes")
		trees = [
			load("res://ground_generation/trees/tree1.tscn"),
			load("res://ground_generation/trees/tree2.tscn"),
			load("res://ground_generation/trees/tree3.tscn"),
			load("res://ground_generation/trees/tree4.tscn")
		]

func _on_data_changed():
	for child in obsticle_folder.get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()

	if trees.size() == 0:
		_load_data()
	
	for i in tree_count:
		var rand_x = (1 if randf() > 0.5 else -1) * randf_range(tree_min, tree_max) * ground.scale.x
		var rand_y = (1 if randf() > 0.5 else -1) * randf_range(tree_min, tree_max) * ground.scale.z
		var rand_rot = deg_to_rad(randf_range(0, 359.99))
		var rand_height = randf_range(-0.1,0.1)
		var rand_scale = randf_range(0.93,1.07)
		var new_tree: Node3D = trees.pick_random().instantiate()
		obsticle_folder.add_child(new_tree)
		new_tree.global_position.x = rand_x
		new_tree.global_position.z = rand_y
		new_tree.global_rotation.y = rand_rot
		var model = new_tree.find_child("model") as HeightComponent
		model.offset = rand_height
		model.scale = model.scale * rand_scale
	
	if navigation_region: navigation_region.call_deferred("bake_navigation_mesh", false)
