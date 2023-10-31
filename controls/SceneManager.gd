class_name SceneManager

static var main_scene: String = "res://world.tscn"
static var main_menu_scene: String = "res://main_menu.tscn"
static var loading_scene: String = "res://loading_screen.tscn"

static func load_main_scene(tree:SceneTree):
	_remove_root(tree)
	var loading = _add_scene(tree, loading_scene).find_child("LoadingBar") as LoadingBar
	loading.on_loaded.connect(func(): 
		_remove_root(tree)
		_finish_add_scene(tree, main_scene)
	)
	loading.set_load(main_scene, "loading world scene")

static func load_main_menu(tree:SceneTree):
	_remove_root(tree)
	_add_scene(tree, main_menu_scene)

static func _remove_node(node:Node):
	for child in node.get_children():
		node.remove_child(child)
		child.call_deferred("free")

static func _remove_root(tree:SceneTree):
	# Remove the current level
	_remove_node(tree.root)

static func _add_scene(tree:SceneTree, scene_name: String) -> Node:
	# Add the next level
	var scene = load(scene_name)
	var next_level = scene.instantiate()
	tree.root.add_child(next_level)
	tree.paused = false
	return next_level

static func _finish_add_scene(tree:SceneTree, scene_name: String):
	var scene = ResourceLoader.load_threaded_get(scene_name)
	var next_level = scene.instantiate()
	tree.root.add_child(next_level)
	tree.paused = false
	return next_level
