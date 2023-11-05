extends Panel

@export var settings_menu: SettingsMenu

func _ready():
	# just to be sure
	Settings._initialize()

func on_quit():
	get_tree().quit()

func on_play():
	settings_menu.close()
	SceneManager.load_loading_scene(get_tree())

func on_settings():
	settings_menu.open()
