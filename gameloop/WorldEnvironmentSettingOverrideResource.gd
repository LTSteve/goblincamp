extends Resource

class_name WorldEnvironmentSettingOverrideResource

@export var fog_setting: SettingResource
@export var fog_density_setting: SettingResource
@export var dof_setting: SettingResource
@export var ssil_setting: SettingResource
@export var ssao_setting: SettingResource
@export var ssr_setting: SettingResource
@export var brightness_setting: SettingResource
@export var contrast_setting: SettingResource
@export var saturation_setting: SettingResource

@export var fog_density_min: float = 0
@export var fog_density_max: float = 1
@export var brightness_min: float = 0.25
@export var brightness_max: float = 2
@export var contrast_min: float = 0.1
@export var contrast_max: float = 2.5
@export var saturation_min: float = 0.1
@export var saturation_max: float = 5

@export var world_environment: Environment
