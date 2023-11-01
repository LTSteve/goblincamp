extends VBoxContainer

class_name Setting

@export var label: Label

@export var setting: SettingResource

func _ready():
	label.text = setting.name

func on_close():
	if setting.update_on_close:
		Settings.save_setting(setting)
