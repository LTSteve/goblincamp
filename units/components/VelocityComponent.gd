extends Node

class_name VelocityComponent

@export var max_speed:float = 100
@export var acceleration:float = 10

var get_max_speed:CallableStack
var get_acceleration:CallableStack

var speed_scale:float = 1.0

var _velocity: Vector2 = Vector2.ZERO

func _ready():
	get_max_speed = CallableStack.new(func(): 
		return max_speed
		, true)
	get_acceleration = CallableStack.new(func():
		return acceleration
		, true)

func accelerate_to_velocity(velocity:Vector2, delta: float):
	var acc = get_acceleration.execute()
	var ad = acc * delta
	_velocity = (_velocity + velocity * ad * speed_scale) / (ad + 1)

func accelerate_in_direction(direction:Vector2, delta: float):
	accelerate_to_velocity(get_max_speed.execute() * direction, delta)

func set_velocity(velocity:Vector2):
	_velocity = velocity

func set_direction(direction:Vector2):
	_velocity = direction * get_max_speed.execute()

func decelerate(delta: float):
	accelerate_to_velocity(Vector2.ZERO, delta)

func move(character_body:CharacterBody3D):
	var dist2 = _velocity.length_squared()
	if dist2 < 0.1:
		if character_body.velocity == Vector3.ZERO: return
		character_body.velocity = Vector3.ZERO
	else:
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
