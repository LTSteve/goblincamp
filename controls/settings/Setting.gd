extends VBoxContainer

class_name Setting

@export var label: Label

@export var setting: SettingResource

func _ready():
	label.text = setting.name
