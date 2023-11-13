extends WorldEnvironment

class_name WorldEnvironmentSettingOverride

@export var resource: WorldEnvironmentSettingOverrideResource

func _ready():
	environment = resource.world_environment
	
	resource.fog_setting.on_change.connect(_setting_changed.bind(environment,"fog_enabled"))
	
	resource.fog_density_setting.on_change.connect(_setting_changed.bind(environment,"fog_density", 
	func(value): return resource.fog_density_min + (resource.fog_density_max - resource.fog_density_min) * value * value))
	
	resource.ssil_setting.on_change.connect(_setting_changed.bind(environment,"ssil_enabled"))
	
	resource.ssao_setting.on_change.connect(_setting_changed.bind(environment,"ssao_enabled"))
	
	resource.ssr_setting.on_change.connect(_setting_changed.bind(environment,"ssr_enabled"))
	
	resource.brightness_setting.on_change.connect(_setting_changed.bind(environment,"adjustment_brightness", 
	func(value): return resource.brightness_min + (resource.brightness_max - resource.brightness_min) * value))
	
	resource.contrast_setting.on_change.connect(_setting_changed.bind(environment,"adjustment_contrast", 
	func(value): return resource.contrast_min + (resource.contrast_max - resource.contrast_min) * value))
	
	resource.saturation_setting.on_change.connect(_setting_changed.bind(environment,"adjustment_saturation", 
	func(value): return resource.saturation_min + (resource.saturation_max - resource.saturation_min) * value))
	
	resource.dof_setting.on_change.connect(_setting_changed.bind(camera_attributes,"dof_blur_far_enabled"))

func _pass_through(value):
	return value

func _setting_changed(new_value, set_object, set_key, transform_value = _pass_through):
	set_object.set(set_key, transform_value.call(new_value))
