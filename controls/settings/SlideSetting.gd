extends Setting

class_name SlideSetting
@onready var icon_off_texture: TextureRect = $"MarginContainer/VBoxContainer/HBoxContainer/Icon_Off"
@onready var icon_full_texture: TextureRect = $"MarginContainer/VBoxContainer/HBoxContainer/Icon_Full"
@onready var slider: Slider = $"MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/HSlider"

func _ready():
	super._ready()
	
	if setting.icon_off:
		icon_off_texture.texture = setting.icon_off
	else:
		icon_off_texture.visible = false
	
	if setting.icon_on:
		icon_full_texture.texture = setting.icon_on
	else:
		icon_full_texture.visible = false
	
	slider.set_value_no_signal(setting.current_value)


func _on_h_slider_drag_ended(_value_changed):
	if !setting.update_on_close:
		setting.current_value = slider.value
		Settings.save_setting(setting)

func on_close():
	if setting.update_on_close:
		setting.current_value = slider.value
	super.on_close()
