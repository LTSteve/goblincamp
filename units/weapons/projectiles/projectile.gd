extends RigidBody3D

class_name Projectile

@export var collision_areas: Array[Area3D]
@export var hit_spot: Node3D

@export var lifespan:float = 10
@export var free_on_hit: bool = true
@export var keep_final_destination: bool = false

@onready var velocity_component: VelocityComponent = $"VelocityComponent"

signal destination_reached()

var direction: Vector2
var target: Unit

var _target_position: Vector3

func _physics_process(delta:float):
	lifespan -= delta
	
	var has_target_position = false
	
	if target && is_instance_valid(target):
		has_target_position = true
		_target_position = target.global_position
	elif keep_final_destination:
		has_target_position = true
	
	if has_target_position:
		direction = Math.unit(Math.v3_to_v2(_target_position - global_position))
		var look = Vector3(_target_position.x,global_position.y,_target_position.z)
		var dist = (look - global_position).length_squared()
		if dist < 0.001:
			if free_on_hit:
				self.queue_free()
				return
			else:
				destination_reached.emit()
		else:
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
	if(free_on_hit):
		self.queue_free()
