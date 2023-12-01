extends UIPopup

@onready var settings_menu: SettingsMenu = $SettingsMenu

func open():
	super.open()
	get_tree().paused = true

func close():
	settings_menu.close()
	get_tree().paused = false
	super.close()

func quit():
	SceneManager.load_main_menu(get_tree())
