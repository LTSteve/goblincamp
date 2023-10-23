extends Panel

class_name SettingsMenu

@export var slide_setting_scene: PackedScene
@export var toggle_setting_scene: PackedScene

var settings_resources: Array[SettingResource]

@onready var settings_container: VBoxContainer = $"MarginContainer/ScrollContainer/VBoxContainer2"

func _ready():
	settings_resources = Settings.get_settings()
	for setting in settings_resources:
		var setting_scene = (slide_setting_scene if setting.setting_type == SettingResource.TYPE.SLIDE else toggle_setting_scene)
		var instance = setting_scene.instantiate() as Setting
		instance.setting = setting
		settings_container.add_child(instance)

func open():
	visible = true

func close():
	#todo: save settings
	visible = false
