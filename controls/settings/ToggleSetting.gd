extends Setting

class_name ToggleSetting

@onready var button: Button = $"MarginContainer/VBoxContainer/MarginContainer2/Button"

func _ready():
	super._ready()
	button.set_pressed_no_signal(setting.current_value)
	
	if setting.icon_off && setting.icon_on:
		button.icon = setting.icon_on if setting.current_value else setting.icon_off
	else: button.visible = false

func _on_button_toggled(button_pressed):
	button.button_pressed = button_pressed
	button.icon = setting.icon_on if button_pressed else setting.icon_off
	
	if !setting.update_on_close:
		setting.current_value = button.button_pressed
		Settings.save_setting(setting)

func on_close():
	if setting.update_on_close:
		setting.current_value = button.button_pressed
	super.on_close()
