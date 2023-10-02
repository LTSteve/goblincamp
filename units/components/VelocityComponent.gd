extends Node

class_name VelocityComponent

@export var max_speed:float = 100
@export var acceleration:float = 10

var _velocity: Vector2 = Vector2.ZERO

func accelerate_to_velocity(velocity:Vector2):
	_velocity = (_velocity + velocity * acceleration) / (acceleration + 1)

func accelerate_in_direction(direction:Vector2):
	accelerate_to_velocity(max_speed * direction)

func set_velocity(velocity:Vector2):
	_velocity = velocity

func decelerate():
	accelerate_to_velocity(Vector2.ZERO)

func move(character_body:CharacterBody3D):
	character_body.velocity = Math.v2_to_v3(_velocity, character_body.global_position.y)
	character_body.move_and_slide()

func apply_delta(delta):
	return _velocity * delta
