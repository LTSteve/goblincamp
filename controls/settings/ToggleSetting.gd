extends Setting

class_name ToggleSetting

@onready var button: Button = $"MarginContainer/VBoxContainer/MarginContainer2/Button"

func _ready():
	super._ready()
	button.set_pressed_no_signal(setting.value)
	button.icon = setting.icon_on if setting.value else setting.icon_off

func _on_button_toggled(button_pressed):
	button.button_pressed = button_pressed
	button.icon = setting.icon_on if button_pressed else setting.icon_off
	
	setting.value = button_pressed
	Settings.save_setting(setting)
