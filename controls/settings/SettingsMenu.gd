extends Panel

class_name SettingsMenu

var slide_setting_scene: PackedScene
var toggle_setting_scene: PackedScene
var action_setting_scene: PackedScene

@export var category_option: OptionButton

var settings_categories: Array[Settings.SettingsCategory]

@onready var settings_container: VBoxContainer = $"MarginContainer/ScrollContainer/VBoxContainer2"

func _ready():
	slide_setting_scene = DB.I.scenes.slide_setting_scene if DB.I else load("res://controls/settings/slide_setting.tscn")
	toggle_setting_scene = DB.I.scenes.toggle_setting_scene if DB.I else load("res://controls/settings/toggle_setting.tscn")
	action_setting_scene = DB.I.scenes.action_setting_scene if DB.I else load("res://controls/settings/action_setting.tscn")
	
	settings_categories = Settings.get_settings_categories()
	for category in settings_categories:
		category_option.add_item(category.name)
	category_option.selected = 0
	_on_option_button_item_selected(0)

func open():
	visible = true

func close():
	_save_settings_container()
	visible = false

func _save_settings_container():
	for setting in settings_container.get_children():
		setting.on_close()

func _clear_settings_container():
	for setting in settings_container.get_children():
		setting.queue_free()

func _create_settings(category:Settings.SettingsCategory):
	for setting in category.settings:
		var setting_scene: PackedScene
		
		match setting.setting_type:
			SettingResource.TYPE.SLIDE:
				setting_scene = slide_setting_scene
			SettingResource.TYPE.TOGGLE:
				setting_scene = toggle_setting_scene
			SettingResource.TYPE.ACTION:
				setting_scene = action_setting_scene
				setting.on_change.connect(func(action): 
					if !action: return
					close()
				)
		
		var instance = setting_scene.instantiate() as Setting
		instance.setting = setting
		
		settings_container.add_child(instance)

func _on_option_button_item_selected(index):
	_save_settings_container()
	_clear_settings_container()
	_create_settings(settings_categories[index])
