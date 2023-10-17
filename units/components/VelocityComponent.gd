extends Node

class_name VelocityComponent

@export var max_speed:float = 100
@export var acceleration:float = 10

var get_max_speed = CallableStack.new(func(): 
	return max_speed
)
var get_acceleration = CallableStack.new(func():
	return acceleration
)

var _velocity: Vector2 = Vector2.ZERO

func accelerate_to_velocity(velocity:Vector2, delta: float):
	var acc = get_acceleration.execute()
	_velocity = (_velocity + velocity * acc * delta) / (acc * delta + 1)

func accelerate_in_direction(direction:Vector2, delta: float):
	accelerate_to_velocity(get_max_speed.execute() * direction, delta)

func set_velocity(velocity:Vector2):
	_velocity = velocity

func set_direction(direction:Vector2):
	_velocity = direction * get_max_speed.execute()

func decelerate(delta: float):
	accelerate_to_velocity(Vector2.ZERO, delta)

func move(character_body:CharacterBody3D):
	character_body.velocity = Math.v2_to_v3(_velocity, 0)
	character_body.move_and_slide()

func move_physics(rigid_body:RigidBody3D, delta:float):
	rigid_body.linear_velocity = Math.v2_to_v3(_velocity, 0)
	rigid_body.move_and_collide(rigid_body.linear_velocity * delta)

func apply_delta(delta):
	return _velocity * delta

func _on_recieved_hit(weapon_hit:Weapon.Hit):
	if !weapon_hit.pushback || weapon_hit.direction == Vector2.ZERO: return
	set_velocity(weapon_hit.direction * weapon_hit.pushback)
