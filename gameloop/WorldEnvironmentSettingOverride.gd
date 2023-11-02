extends WorldEnvironment

class_name WorldEnvironmentSettingOverride

@export var resource: WorldEnvironmentSettingOverrideResource

var _fog_toggle: bool = false
var _fog_density: float = 0.5
var _dof_toggle: bool = false
var _ssil_toggle: bool = false
var _ssao_toggle: bool = false
var _ssr_toggle: bool = false
var _brightness: float = 0.5
var _contrast: float = 0.5
var _saturation: float = 0.5

func _process(_delta):
	if _fog_toggle != resource.fog_setting.current_value:
		_fog_toggle = resource.fog_setting.current_value
		environment.fog_enabled = _fog_toggle

	if _fog_density != resource.fog_density_setting.current_value:
		_fog_density = resource.fog_density_setting.current_value
		environment.fog_density = resource.fog_density_min + (resource.fog_density_max - resource.fog_density_min) * _fog_density * _fog_density

	if _dof_toggle != resource.dof_setting.current_value:
		_dof_toggle = resource.dof_setting.current_value
		camera_attributes.dof_blur_far_enabled = _dof_toggle

	if _ssil_toggle != resource.ssil_setting.current_value:
		_ssil_toggle = resource.ssil_setting.current_value
		environment.ssil_enabled = _ssil_toggle

	if _ssao_toggle != resource.ssao_setting.current_value:
		_ssao_toggle = resource.ssao_setting.current_value
		environment.ssao_enabled = _ssao_toggle

	if _ssr_toggle != resource.ssr_setting.current_value:
		_ssr_toggle = resource.ssr_setting.current_value
		environment.ssr_enabled = _ssr_toggle
	
	if _brightness != resource.brightness_setting.current_value:
		_brightness = resource.brightness_setting.current_value
		environment.adjustment_brightness = resource.brightness_min + (resource.brightness_max - resource.brightness_min) * _brightness
	
	if _contrast != resource.contrast_setting.current_value:
		_contrast = resource.contrast_setting.current_value
		environment.adjustment_contrast = resource.contrast_min + (resource.contrast_max - resource.contrast_min) * _contrast
	
	if _saturation != resource.saturation_setting.current_value:
		_saturation = resource.saturation_setting.current_value
		environment.adjustment_saturation = resource.saturation_min + (resource.saturation_max - resource.saturation_min) * _saturation
