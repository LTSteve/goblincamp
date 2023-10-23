extends AnimationPlayer

@export var starting_animation: String = "movement"

@export var standing_speed_scale: float = 0.8
@export var walking_speed_scale: float = 1
@export var running_speed_scale: float = 1.5

@export var random_component_scale: float = 0.1

var _random_component:float

func _ready():
	_random_component = randf_range(0,random_component_scale)
	play(starting_animation)
	speed_scale = standing_speed_scale + _random_component

func _on_velocity_component_is_running():
	speed_scale = running_speed_scale + _random_component

func _on_velocity_component_is_walking():
	speed_scale = walking_speed_scale + _random_component

func _on_velocity_component_is_stopping():
	speed_scale = standing_speed_scale + _random_component
