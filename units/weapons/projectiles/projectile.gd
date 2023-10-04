extends RigidBody3D

class_name Projectile

@export var collision_areas: Array[Area3D]

@export var lifespan:float = 10

@onready var velocity_component: VelocityComponent = $"VelocityComponent"

var direction: Vector2
var target: Unit

func _physics_process(delta:float):
	lifespan -= delta
	
	if target && is_instance_valid(target):
		direction = Math.unit(Math.v3_to_v2(target.global_position - global_position))
		look_at(Vector3(target.global_position.x,global_position.y,target.global_position.z))
	else:
		look_at(global_position + Math.v2_to_v3(direction, global_position.y))
	
	rotation = Vector3(0, rotation.y, 0)
	
	if direction == Vector2.ZERO || lifespan <= 0:
		self.queue_free()
		return
	
	velocity_component.set_direction(direction)
	velocity_component.move_physics(self, delta)

func _on_area_3d_body_entered(_body):
	self.queue_free()
