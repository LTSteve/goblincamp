extends Panel

@export var settings_menu: SettingsMenu

func on_quit():
	get_tree().quit()

func on_play():
	settings_menu.close()
	SceneManager.load_main_scene(get_tree())

func on_settings():
	settings_menu.open()
