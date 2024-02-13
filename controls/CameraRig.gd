extends Node3D

class_name CameraRig

static var I:CameraRig

@export var camera_angle_min: float = 10
@export var camera_angle_max: float = 90
@export var camera_distance_min: float = 2
@export var camera_distance_max: float = 30

@export var camera_scroll_speed: float = 80
@export var camera_rotation_speed: float = 90
@export var camera_angle_speed: float = 20
@export var camera_distance_speed: float = 3

@export var drag_speed: float = 4.0

@export var auto_drive: bool
@export var no_drive: bool

@export var fov_setting: SettingResource

@onready var camera_rotation: Node3D = $"CameraRotation"
@onready var camera_angle: Node3D = $"CameraRotation/CameraAngle"
@onready var camera_distance: Node3D = $"CameraRotation/CameraAngle/CameraDistance"
@onready var camera: Camera3D = $"CameraRotation/CameraAngle/CameraDistance/Camera3D"

@onready var velocity_component: VelocityComponent = $"VelocityComponent"

@onready var card_container: CardContainer = $"CameraRotation/CameraAngle/CameraDistance/Camera3D/card_container"

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

var left_right_input: float
var forward_back_input: float
var rotate_input: float
var angle_input: float
var distance_input: float

var _angle_override:CameraSettings

class CameraSettings:
	var locked_to_offset: Vector2 = Vector2.ZERO
	var locked_to: Unit
	var lock_strength: float = 0

func _ready():
	I = self
	angle_value = camera_angle_min + (camera_angle_max - camera_angle_min) / 2.0
	distance_value = camera_distance_min + (camera_distance_max - camera_distance_min) / 2.0
	
	fov_setting.on_change.connect(_fov_change)
	_fov_change(fov_setting.current_value)

func _fov_change(new_fov):
	camera.fov = clampf(25.0 + 110 * new_fov, 45, 179)

func _process(delta):
	if _angle_override != null:
		velocity_component.set_velocity(Vector2.ZERO)
		var pos := Vector2(_angle_override.locked_to.global_position.x, _angle_override.locked_to.global_position.z) + _angle_override.locked_to_offset
		global_position = lerp(global_position, Math.v2_to_v3(pos, Ground.sample_height(pos.x, pos.y)), _angle_override.lock_strength)
	
	if auto_drive:
		forward_back_input = -1
		rotate_input = 1
	elif !no_drive:
		var drag_v2:Vector2 = TouchAndMouseInput.I.get_current_drag_v2()
		#input
		if _angle_override:
			left_right_input = 0
			forward_back_input = 0
		else:
			left_right_input = _combine_actions("camera_right", "camera_left") * camera_scroll_speed - drag_v2.x * drag_speed
			forward_back_input = _combine_actions("camera_back", "camera_forward") * camera_scroll_speed - drag_v2.y * drag_speed
		rotate_input = _combine_actions("camera_rotate_right", "camera_rotate_left")
		angle_input = _combine_actions("camera_angle_up", "camera_angle_down")
		distance_input = _combine_actions("camera_zoom", "camera_dezoom")
	
	#movement
	var desired_movement := left_right_input * Vector3.LEFT + forward_back_input * Vector3.FORWARD
	
	velocity_component.accelerate_to_velocity(Math.v3_to_v2(desired_movement), delta)
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

func _combine_actions(positive_input:String, negative_input:String) -> float:
	return (Input.get_action_strength(positive_input) - Input.get_action_strength(negative_input)) as float

func set_camera_angle_override(cam_settings:CameraSettings):
	var tween = self.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(cam_settings, "lock_strength", 1.0, 0.5)
	
	_angle_override = cam_settings

func unset_camera_angle_override():
	_angle_override = null

func calculate_vendor_offset() -> Vector2:
	#take camera main position, add camera distance length to this position, in the direction right of the camera facing
	var cam_right := camera.global_basis.x
	
	return Math.v3_to_v2(cam_right * distance_value * 0.7)
