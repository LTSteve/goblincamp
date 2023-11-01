extends Setting

class_name SlideSetting
@onready var icon_off_texture: TextureRect = $"MarginContainer/VBoxContainer/HBoxContainer/Icon_Off"
@onready var icon_full_texture: TextureRect = $"MarginContainer/VBoxContainer/HBoxContainer/Icon_Full"
@onready var slider: Slider = $"MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/HSlider"

func _ready():
	super._ready()
	
	icon_off_texture.texture = setting.icon_off
	icon_full_texture.texture = setting.icon_on
	
	slider.set_value_no_signal(setting.value)


func _on_h_slider_drag_ended(value_changed):
	if ! value_changed: return
	
	if !setting.update_on_close:
		setting.value = slider.value
		Settings.save_setting(setting)

func on_close():
	if setting.update_on_close:
		setting.value = slider.value
	super.on_close()
