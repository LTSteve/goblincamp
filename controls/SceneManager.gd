class_name SceneManager

static var main_scene: String = "res://world.tscn"
static var main_menu_scene: String = "res://main_menu.tscn"

static func load_main_scene(tree:SceneTree):
	_remove_root(tree)
	_add_scene(tree, main_scene)

static func load_main_menu(tree:SceneTree):
	_remove_root(tree)
	_add_scene(tree, main_menu_scene)

static func _remove_root(tree:SceneTree):
	# Remove the current level
	for child in tree.root.get_children():
		tree.root.remove_child(child)
		child.call_deferred("free")

static func _add_scene(tree:SceneTree, scene_name: String):
	# Add the next level
	var scene = load(scene_name)
	var next_level = scene.instantiate()
	tree.root.add_child(next_level)
	tree.paused = false
