extends Setting

class_name ActionSetting

@onready var button: Button = $"MarginContainer/VBoxContainer/MarginContainer2/Button"

func _ready():
	button.text = setting.name

func on_close():
	if setting.update_on_close:
		setting.current_value = button.button_pressed
	super.on_close()

func _on_button_pressed():
	setting.current_value = true
	if !setting.update_on_close:
		setting.current_value = button.button_pressed
		Settings.save_setting(setting)
