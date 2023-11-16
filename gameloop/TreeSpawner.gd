@tool

extends Node

class_name TreeSpawner

@export var clear: bool:
	set(_value):
		clear = false
		_clear()

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
@export var tree_scale: Vector3 = Vector3.ONE
@export var skip_collision_boxes: bool = false

var tree_multimesh_scene: PackedScene
var trees: Array[PackedScene] = []
var tree_meshes: Array[Mesh] = []

var tree_multi_meshes: Array[MultiMeshInstance3D] = []

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
		tree_meshes = [
			DB.I.scenes.tree1_mesh,
			DB.I.scenes.tree2_mesh,
			DB.I.scenes.tree3_mesh,
			DB.I.scenes.tree4_mesh
		]
		tree_multimesh_scene = DB.I.scenes.scatter_multimesh_scene
	else:
		trees = [
			load("res://ground_generation/trees/tree1.tscn"),
			load("res://ground_generation/trees/tree2.tscn"),
			load("res://ground_generation/trees/tree3.tscn"),
			load("res://ground_generation/trees/tree4.tscn")
		]
		tree_meshes = [
			load("res://models/trees/tree_1_Icosphere_003.res"),
			load("res://models/trees/tree_2_Cube_001.res"),
			load("res://models/trees/tree_3_Cube_002.res"),
			load("res://models/trees/tree_4_Cube_003.res")
		]
		tree_multimesh_scene = load("res://ground_generation/scatter_multimesh.tscn")


func _update_multi_meshes():
	#spawn multimeshes
	tree_multi_meshes = []

	for mesh in tree_meshes:
		var new_mm = tree_multimesh_scene.instantiate() as MultiMeshInstance3D
		
		new_mm.multimesh = MultiMesh.new()
		new_mm.multimesh.transform_format = MultiMesh.TRANSFORM_3D
		new_mm.multimesh.mesh = mesh
		new_mm.multimesh.instance_count = tree_count
		
		tree_multi_meshes.append(new_mm)
		obsticle_folder.add_child(new_mm)

func _clear():
	for child in obsticle_folder.get_children():
		if Engine.is_editor_hint():
			child.free()
		else:
			child.queue_free()

func _on_data_changed():
	_clear()
	
	if trees.size() == 0:
		_load_data()
	
	#create tree multimeshes
	_update_multi_meshes()
	
	for i in tree_count:
		#4 types of tree
		for mesh_i in 4: 
			var rand_v2 = Math.rand_v2_range(tree_min, tree_max)
			var rand_x = rand_v2.x * ground.scale.x
			var rand_y = rand_v2.y * ground.scale.z
			var rand_rot = Math.random_rotation()
			var rand_height = randf_range(-0.1,0.1)
			var rand_scale = randf_range(0.93,1.07)
			
			var ground_height = Ground.sample_height(rand_x,rand_y)
			
			if !skip_collision_boxes:
				var new_tree = trees[mesh_i].instantiate() as Node3D
				obsticle_folder.add_child(new_tree)
				new_tree.global_position.x = rand_x
				new_tree.global_position.z = rand_y
			
			var random_transform = Transform3D.IDENTITY
			random_transform = random_transform.rotated(Vector3.UP, rand_rot)
			random_transform = random_transform.scaled(Vector3(rand_scale * tree_scale.x, (rand_scale + rand_height) * tree_scale.y, rand_scale * tree_scale.z))
			random_transform = random_transform.translated(Vector3(rand_x, ground_height, rand_y))
			
			tree_multi_meshes[mesh_i].multimesh.set_instance_transform(i, random_transform)
	
	if navigation_region: navigation_region.call_deferred("bake_navigation_mesh", false)
