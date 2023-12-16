extends Resource

class_name SettingResource

enum TYPE {SLIDE,TOGGLE,ACTION}

@export var name: String
@export var icon_off: Texture
@export var icon_on: Texture
@export var setting_type: TYPE
@export var default_setting_value_toggle: bool = false
@export var default_setting_value_slide: float = 1.0
@export var update_on_close: bool = false

signal on_change(new_value)

var value_has_been_set:bool = false
var current_value: 
	get:
		if !value_has_been_set:
			if setting_type == TYPE.SLIDE:
				return default_setting_value_slide
			elif setting_type == TYPE.TOGGLE:
				return default_setting_value_toggle
			else:
				return false
		else:
			return current_value
	set(value):
		if current_value != value || !value_has_been_set:
			value_has_been_set = true
			current_value = value if setting_type != TYPE.ACTION else false
			on_change.emit(value)

var default_setting:
	get:
		match setting_type:
			TYPE.SLIDE:
				return default_setting_value_slide
			TYPE.TOGGLE:
				return default_setting_value_toggle
			TYPE.ACTION:
				return false
		return default_setting_value_slide
