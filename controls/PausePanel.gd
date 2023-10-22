extends Panel

@onready var settings_menu = $SettingsMenu

func toggle():
	if visible:
		close()
	else:
		open()

func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false
	close_settings()

func open_settings():
	settings_menu.visible = true

func close_settings():
	#todo: save settings
	settings_menu.visible = false

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()
