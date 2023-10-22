extends Resource

class_name SettingResource

enum TYPE {SLIDE,TOGGLE}

@export var name: String
@export var icon_off: Texture
@export var icon_on: Texture
@export var setting_type: TYPE
@export var default_setting_value_toggle: bool = false
@export var default_setting_value_slide: float = 1.0
