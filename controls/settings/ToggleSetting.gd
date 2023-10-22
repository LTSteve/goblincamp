extends Setting

class_name ToggleSetting

@onready var button: Button = $"MarginContainer/VBoxContainer/MarginContainer2/Button"

func _ready():
	super._ready()
	button.button_pressed = setting.default_setting_value_toggle
	button.icon = setting.icon_on if setting.default_setting_value_toggle else setting.icon_off


func _on_button_toggled(button_pressed):
	button.button_pressed = button_pressed
	button.icon = setting.icon_on if button_pressed else setting.icon_off
	#do something with button_pressed
