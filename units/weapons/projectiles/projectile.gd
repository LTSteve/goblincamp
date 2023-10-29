extends Area3D

class_name Projectile

@export var hit_spot: Node3D

@export var lifespan:float = 10
@export var free_on_hit: bool = true
@export var keep_final_destination: bool = false

@export var leave_behind_sfx_scene: PackedScene
@export var sfx: Array[AudioStream]

@export var model: Node3D
@export var particles: GPUParticles3D

@onready var velocity_component: VelocityComponent = $"VelocityComponent"

signal destination_reached()

var direction: Vector2
var target: Unit

var find_new_targets: bool = false
var find_pool: Array[Unit]

var _target_position: Vector3

func _ready():
	Global.projectiles.append(self)

func _on_tree_exiting():
	Global.projectiles = Global.projectiles.filter(func(projectile): return projectile != self)

func do_move(delta: float):
	lifespan -= delta
	
	if !is_instance_valid(target):
		target = null
	
	if !target && find_new_targets:
		target = Global.nearest_unit(find_pool, global_position)
	
	var has_target_position = false
	
	if target:
		has_target_position = true
		_target_position = target.global_position
	elif keep_final_destination:
		has_target_position = true
	
	if has_target_position:
		direction = Math.v3_to_v2(_target_position - global_position).normalized()
	
	if (has_target_position && _target_position.distance_squared_to(global_position) < 0.01) || lifespan <= 0:
		if free_on_hit || lifespan <= 0:
			_queue_free_self()
		else:
			destination_reached.emit()
		return
	
	_try_look_in_direction(direction)
	
	velocity_component.set_direction(direction)
	velocity_component.move_basic(self, delta)

func _try_look_in_direction(dir:Vector2):
	look_at(global_position + Math.v2_to_v3(dir))

func _on_area_3d_body_entered(_body):
	if(free_on_hit):
		_queue_free_self()
	if leave_behind_sfx_scene:
		var leave_behind = leave_behind_sfx_scene.instantiate() as LeaveBehindSFX
		leave_behind.stream = sfx.pick_random()
		get_tree().root.add_child.call_deferred(leave_behind)

func _queue_free_self():
	if model: model.visible = false
	if particles: particles.emitting = false
	set_deferred("monitoring", false)
	Wait.timer(1.0, self, _free_self)

func _free_self():
	self.queue_free()
