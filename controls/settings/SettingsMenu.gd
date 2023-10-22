extends Panel

@export var slide_setting_scene: PackedScene
@export var toggle_setting_scene: PackedScene
@export var settings_resources: Array[SettingResource]

@onready var title_label: Label = $"MarginContainer/VBoxContainer2/Label"

func _ready():
	for setting in settings_resources:
		var setting_scene = (slide_setting_scene if setting.setting_type == SettingResource.TYPE.SLIDE else toggle_setting_scene)
		var instance = setting_scene.instantiate() as Setting
		instance.setting = setting
		title_label.add_sibling(instance)
