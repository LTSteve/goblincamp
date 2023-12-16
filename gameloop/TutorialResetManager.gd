extends Node

class_name TutorialResetManager

@export var tutorial_reset_setting: SettingResource

var cfg_file:ConfigFile

func _ready():
	tutorial_reset_setting.on_change.connect(_reset_tutorial)

func _exit_tree():
	tutorial_reset_setting.on_change.disconnect(_reset_tutorial)

func _reset_tutorial(action):
	if !action: return
	
	if !cfg_file:
		cfg_file = ConfigFile.new()
	if cfg_file.load(TutorialManager.cfg_file_name) == ERR_FILE_CANT_OPEN:
		printerr("Couldn't open tutorial cfg!")
	cfg_file.clear()
	cfg_file.save(TutorialManager.cfg_file_name)
