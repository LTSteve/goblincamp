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

func _ready():
	Global.projectiles.append(self)

func _on_tree_exiting():
	Global.projectiles = Global.projectiles.filter(func(projectile): return projectile != self)

func do_move(delta: float):
	lifespan -= delta
	
	var has_target_position = false
	
	if target && is_instance_valid(target):
		has_target_position = true
		_target_position = target.global_position
	elif keep_final_destination:
		has_target_position = true
	
	if has_target_position:
		direction = Math.unit_v2(Math.v3_to_v2(_target_position - global_position))
	
	if direction.length_squared() < 0.01 || lifespan <= 0:
		if free_on_hit || lifespan <= 0:
			self.queue_free()
		else:
			destination_reached.emit()
		return
	
	_try_look_in_direction(direction)
	
	velocity_component.set_direction(direction)
	velocity_component.move_physics(self, delta)

func _try_look_in_direction(dir:Vector2):
	look_at(global_position + Math.v2_to_v3(dir))

func _on_area_3d_body_entered(_body):
	if(free_on_hit):
		self.queue_free()
