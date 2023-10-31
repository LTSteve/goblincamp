extends Node

class_name DB

static var I: DB

var _resource_folders = {
	blacksmith_deck = "res://card_modifiers/blacksmith",
	enchanter_deck = "res://card_modifiers/enchanter",
	leatherworker_deck = "res://card_modifiers/leatherworker",
	enemy_deck = "res://card_modifiers/enemy",
	settings = "res://controls/settings_types",
	enemy_spawns = "res://enemy_spawns"
}

var _scene_paths = {
	aoe_scene = "res://fx/generic_aoe.tscn",
	explosion_scene = "res://fx/explosion.tscn",
	ember_scene = "res://units/weapons/projectiles/ember.tscn",
	taste_for_blood_scene = "res://fx/generic_aoe.tscn",
	leave_behind_sfx_scene = "res://sfx/leave_behind_sfx.tscn",
	knight_scene = "res://units/knight.tscn",
	witch_scene = "res://units/witch.tscn",
	woodsman_scene = "res://units/woodsman.tscn",
	goblin_scene = "res://units/goblin.tscn",
	ogre_scene = "res://units/ogre.tscn",
	imp_scene = "res://units/imp.tscn",
	goblin_priest_scene = "res://units/goblin_priest.tscn",
	blacksmith_scene = "res://buildings/blacksmith.tscn",
	leatherworker_scene = "res://buildings/leatherworker.tscn",
	enchanter_scene = "res://buildings/enchanter.tscn",
	damage_label_settings = "res://units/components/damagelabel/damage_label_settings.tres"
}

var scenes = {}

var resource_groups = {}

#really shouldn't be doing UI and loading stuff in the same class but w/e
@export var loading_bar: LoadingBar
@export var loading_panel: ColorRect

func _ready():
	I = self
	
	loading_bar.on_loaded.connect(_loading_finished)
	
	for scene_name in _scene_paths.keys():
		loading_bar.set_load(_scene_paths[scene_name], "preloading resources")
	
	for dir_name in _resource_folders.keys():
		var paths = _get_resource_paths(_resource_folders[dir_name])
		for path in paths:
			loading_bar.set_load(path, "preloading resources")

func _loading_finished():
	for scene_name in _scene_paths.keys():
		scenes[scene_name] = ResourceLoader.load_threaded_get(_scene_paths[scene_name])
	
	for dir_name in _resource_folders.keys():
		var paths = _get_resource_paths(_resource_folders[dir_name])
		resource_groups[dir_name] = []
		for path in paths:
			resource_groups[dir_name].append(ResourceLoader.load_threaded_get(path))
	
	loading_panel.visible = false

func _get_resource_paths(resource_folder:String):
	var to_return = []
	var directory = DirAccess.open(resource_folder)
	var files = directory.get_files()
	
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		to_return.append(resource_folder + "/" + file)
	
	return to_return
