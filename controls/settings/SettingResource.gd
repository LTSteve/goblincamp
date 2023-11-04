extends Resource

class_name SettingResource

enum TYPE {SLIDE,TOGGLE}

@export var name: String
@export var icon_off: Texture
@export var icon_on: Texture
@export var setting_type: TYPE
@export var default_setting_value_toggle: bool = false
@export var default_setting_value_slide: float = 1.0
@export var update_on_close: bool = false

var value_has_been_set:bool = false
var current_value: 
	get:
		if !value_has_been_set:
			if setting_type == TYPE.SLIDE:
				return default_setting_value_slide
			else:
				return default_setting_value_toggle
		else:
			return current_value
	set(value):
		value_has_been_set = true
		current_value = value

var default_setting:
	get:
		match setting_type:
			TYPE.SLIDE:
				return default_setting_value_slide
			TYPE.TOGGLE:
				return default_setting_value_toggle
		return default_setting_value_slide
