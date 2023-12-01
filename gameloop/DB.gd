extends Node

class_name DB

static var I: DB

var _observables_folder = "res://observables"

var _resource_folders = {
	blacksmith_deck = "res://card_modifiers/blacksmith",
	enchanter_deck = "res://card_modifiers/enchanter",
	leatherworker_deck = "res://card_modifiers/leatherworker",
	tavern_deck = "res://card_modifiers/tavern",
	ritual_deck = "res://card_modifiers/rituals",
	enemy_deck = "res://card_modifiers/enemy",
	settings = "res://controls/settings_types"
}

var _scene_paths = {
	aoe_scene = "res://fx/generic_aoe.tscn",
	explosion_scene = "res://fx/explosion.tscn",
	deth_ball_scene = "res://fx/deth_ball.tscn",
	ember_scene = "res://units/weapons/projectiles/ember.tscn",
	arrow_scene= "res://units/weapons/projectiles/arrow.tscn",
	fireball_scene= "res://units/weapons/projectiles/fireball.tscn",
	taste_for_blood_scene = "res://fx/generic_aoe.tscn",
	leave_behind_sfx_scene = "res://sfx/leave_behind_sfx.tscn",
	knight_scene = "res://units/knight.tscn",
	witch_scene = "res://units/witch.tscn",
	woodsman_scene = "res://units/woodsman.tscn",
	bearkin_scene = "res://units/bearkin.tscn",
	goblin_scene = "res://units/goblin.tscn",
	ogre_scene = "res://units/ogre.tscn",
	imp_scene = "res://units/imp.tscn",
	goblin_priest_scene = "res://units/goblin_priest.tscn",
	blacksmith_scene = "res://buildings/blacksmith.tscn",
	leatherworker_scene = "res://buildings/leatherworker.tscn",
	enchanter_scene = "res://buildings/enchanter.tscn",
	tavern_scene = "res://buildings/tavern.tscn",
	damage_label_settings = "res://units/components/damagelabel/damage_label_settings.tres",
	rock1_mesh = "res://models/rocks/rock1_Cube.res",
	rock2_mesh = "res://models/rocks/rock2_Cube_001.res",
	rock3_mesh = "res://models/rocks/rock3_Cube_002.res",
	grass1_mesh = "res://models/grass/grass1_Plane_001.res",
	grass2_mesh = "res://models/grass/grass2_Plane_003.res",
	tree1_scene = "res://ground_generation/trees/tree1.tscn",
	tree2_scene = "res://ground_generation/trees/tree2.tscn",
	tree3_scene = "res://ground_generation/trees/tree3.tscn",
	tree4_scene = "res://ground_generation/trees/tree4.tscn",
	basic_burst_scene= "res://units/burst_scenes/basic_burst.tscn",
	heal_burst_scene= "res://units/burst_scenes/heal_burst.tscn",
	fire_burst_scene= "res://units/burst_scenes/fire_burst.tscn",
	bleed_burst_scene= "res://units/burst_scenes/bleed_burst.tscn",
	cold_burst_scene= "res://units/burst_scenes/cold_burst.tscn",
	offer_display_scene= "res://controls/offer_display.tscn",
	ritual_display_scene= "res://controls/ritual_display.tscn",
	goblin_ear_scene="res://pickups/goblin_ear.tscn",
	resource_cost_scene= "res://controls/resource_cost.tscn",
	card_display_scene= "res://controls/cards/card_display.tscn",
	damage_label_scene= "res://units/components/damagelabel/damage_label.tscn",
	slide_setting_scene= "res://controls/settings/slide_setting.tscn",
	toggle_setting_scene= "res://controls/settings/toggle_setting.tscn",
	scatter_multimesh_scene= "res://ground_generation/scatter_multimesh.tscn",
	tree1_mesh= "res://models/trees/tree_1_Icosphere_003.res",
	tree2_mesh= "res://models/trees/tree_2_Cube_001.res",
	tree3_mesh= "res://models/trees/tree_3_Cube_002.res",
	tree4_mesh= "res://models/trees/tree_4_Cube_003.res",
	building_project_panel_scene= "res://controls/popups/building_project_panel.tscn",
	buy_panel_scene= "res://controls/popups/buy_panel.tscn",
	game_over_panel_scene= "res://controls/popups/game_over_panel.tscn",
	goblin_card_panel_scene= "res://controls/popups/goblin_card_panel.tscn",
	pause_panel_scene= "res://controls/popups/pause_panel.tscn",
	pick_project_scene= "res://controls/popups/pick_project.tscn",
	ritual_panel_scene= "res://controls/popups/ritual_panel.tscn",
	knight_unit_cam= "res://units/unit_cams/knight_cam.tscn",
	witch_unit_cam= "res://units/unit_cams/witch_cam.tscn",
	woodsman_unit_cam= "res://units/unit_cams/woodsman_cam.tscn",
	bearkin_unit_cam= "res://units/unit_cams/bearkin_cam.tscn",
	blacksmith_cam= "res://buildings/building_cams/blacksmith_cam.tscn",
	leatherworker_cam= "res://buildings/building_cams/leatherworker_cam.tscn",
	enchanter_cam= "res://buildings/building_cams/enchanter_cam.tscn",
	tavern_cam= "res://buildings/building_cams/tavern_cam.tscn",
}

var scenes = {}

var resource_groups = {}

var observables = {}

#really shouldn't be doing UI and loading stuff in the same class but w/e
@export var loading_bar: LoadingBar
@export var loading_scene: Node3D

func _ready():
	I = self
	
	call_deferred("_post_init")

func _post_init():
	loading_bar.set_load(SceneManager.main_scene)
	
	for scene_name in _scene_paths.keys():
		loading_bar.set_load(_scene_paths[scene_name], "preloading resources")
	
	for dir_name in _resource_folders.keys():
		var paths = _get_resource_paths(_resource_folders[dir_name])
		
		for path in paths:
			loading_bar.set_load(path, "preloading resources")
	
	var observables_paths = _get_resource_paths(_observables_folder)
	for path in observables_paths:
		loading_bar.set_load(path, "preloading resources")
	
	loading_bar.on_loaded.connect(_loading_finished)

func _loading_finished(loaded:Array[Resource]):
	for scene_name in _scene_paths.keys():
		scenes[scene_name] = Global.find_by_func(loaded, func(ld:Resource): return ld.resource_path == _scene_paths[scene_name])
	
	for dir_name in _resource_folders.keys():
		var paths = _get_resource_paths(_resource_folders[dir_name])
		resource_groups[dir_name] = []
		for path in paths:
			var res = Global.find_by_func(loaded, func(ld:Resource): return ld.resource_path == path)
			resource_groups[dir_name].append(res)
	
	var observables_paths = _get_resource_paths(_observables_folder)
	for path in observables_paths:
		var res = Global.find_by_func(loaded, func(ld:Resource): return ld.resource_path == path)
		# this is interesting, I could implement interfaces
		# something like Initializable.is_applied(obj), Initialize.assert_applied(self), etc
		if res.has_method("initialize"): res.initialize()
		observables[res.resource_name] = res
	
	SceneManager.load_main_scene(get_tree(), loaded)
	
	loading_scene.queue_free()

func _get_resource_paths(resource_folder:String):
	var to_return = []
	var directory = DirAccess.open(resource_folder)
	var files = directory.get_files()
	
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		to_return.append(resource_folder + "/" + file)
	
	return to_return
