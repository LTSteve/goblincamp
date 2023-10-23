extends Panel

@onready var settings_menu: SettingsMenu = $SettingsMenu

func toggle():
	if visible:
		close()
	else:
		open()

func open():
	get_tree().paused = true
	visible = true

func close():
	settings_menu.close()
	get_tree().paused = false
	visible = false

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()

func quit():
	SceneManager.load_main_menu(get_tree())
