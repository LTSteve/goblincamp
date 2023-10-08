extends Node3D

@export var camera_angle_min: float = 10
@export var camera_angle_max: float = 90
@export var camera_distance_min: float = 2
@export var camera_distance_max: float = 30

@export var camera_scroll_speed: float = 10
@export var camera_rotation_speed: float = 90
@export var camera_angle_speed: float = 20
@export var camera_distance_speed: float = 3

@onready var camera_rotation: Node3D = $"CameraRotation"
@onready var camera_angle: Node3D = $"CameraRotation/CameraAngle"
@onready var camera_distance: Node3D = $"CameraRotation/CameraAngle/CameraDistance"
@onready var camera: Camera3D = $"CameraRotation/CameraAngle/CameraDistance/Camera3D"

@onready var velocity_component: VelocityComponent = $"VelocityComponent"

var rotation_value: float:
	get:
		return rotation_value
	set(value):
		rotation_value = value

var angle_value: float:
	get:
		return angle_value
	set(value):
		angle_value = clampf(value,camera_angle_min,camera_angle_max)

var distance_value: float:
	get:
		return distance_value
	set(value):
		distance_value = clampf(value,camera_distance_min,camera_distance_max)

var left_right_input: int
var forward_back_input: int
var rotate_input: int
var angle_input: int
var distance_input: int

func _ready():
	angle_value = camera_angle_min + (camera_angle_max - camera_angle_min) / 2.0
	distance_value = camera_distance_min + (camera_distance_max - camera_distance_min) / 2.0

func _process(delta):
	#input
	left_right_input = _combine_actions("camera_right", "camera_left")
	forward_back_input = _combine_actions("camera_back", "camera_forward")
	rotate_input = _combine_actions("camera_rotate_right", "camera_rotate_left")
	angle_input = _combine_actions("camera_angle_up", "camera_angle_down")
	distance_input = _combine_actions("camera_zoom", "camera_dezoom")
	
	#movement
	var desired_movement = Math.unit(left_right_input * Vector3.LEFT + forward_back_input * Vector3.FORWARD)
	
	velocity_component.accelerate_in_direction(Math.v3_to_v2(desired_movement) * camera_scroll_speed, delta)
	translate(camera_rotation.quaternion * Math.v2_to_v3(velocity_component.apply_delta(delta), global_position.y))
	global_position.y = Ground.sample_height(camera.global_position.x, camera.global_position.z) + 0.1
	
	#rotation
	rotation_value += rotate_input * camera_rotation_speed * delta
	camera_rotation.rotation_degrees = Vector3(0,rotation_value,0)
	
	#angle
	angle_value += angle_input * camera_angle_speed * delta
	camera_angle.rotation_degrees = Vector3(angle_value,0,0)
	
	#distance
	distance_value += distance_input * camera_distance_speed * delta
	camera_distance.position = Vector3(0,0,-distance_value)
	
	

func _combine_actions(positive_input:String, negative_input:String) -> int:
	return (Input.get_action_strength(positive_input) - Input.get_action_strength(negative_input)) as int
