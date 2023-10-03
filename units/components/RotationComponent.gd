extends Node

class_name RotationComponent

@export var fast_rotation_speed:float = 360
@export var slow_rotation_speed:float = 200
@export var fast_rotation_cutoff: float = 50

var _direction: Vector2 = Vector2.RIGHT

func snap_to_direction(direction:Vector2):
	_direction = Math.unit(direction)

func turn_to_direction(direction:Vector2, delta):
	if direction == Vector2.ZERO: return
	
	var fast_rotation_speed_r = deg_to_rad(fast_rotation_speed)
	var slow_rotation_speed_r = deg_to_rad(slow_rotation_speed)
	var fast_rotation_cutoff_r = deg_to_rad(fast_rotation_cutoff)
	
	var desired_angle_change = _direction.angle_to(direction)
	var velocity = 0
	
	if desired_angle_change > 0:
		velocity = fast_rotation_speed_r if desired_angle_change > fast_rotation_cutoff_r else slow_rotation_speed_r
	if desired_angle_change < 0:
		velocity = -fast_rotation_speed_r if -desired_angle_change > fast_rotation_cutoff_r else -slow_rotation_speed_r
	
	velocity *= delta
	
	if Math.crosses_zero(desired_angle_change, _direction.rotated(velocity).angle_to(direction)):
		velocity = desired_angle_change
	
	_direction = _direction.rotated(velocity)

func apply_rotation(character_body:CharacterBody3D):
	character_body.look_at(Math.v2_to_v3(_direction + Math.v3_to_v2(character_body.global_position), character_body.global_position.y))
