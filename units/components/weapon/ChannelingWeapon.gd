extends Weapon

class_name ChannelingWeapon

@export var aoe_scene: PackedScene
@export var aoe_spawn_point: Node3D

var _current_target:Vector3
var _current_target_enemy: bool
var _active_aoe: AreaOfEffect
var _velocity_component: VelocityComponent

func _physics_process(delta):
	if !is_instance_valid(_active_aoe): return
	
	if _current_target == _active_aoe.global_position: return
	
	var movement_separation = Math.v3_to_v2(_current_target - _active_aoe.global_position)
	if movement_separation.length_squared() <= (_velocity_component.get_max_speed.execute() * delta):
		_active_aoe.global_position = Math.v2_to_v3(Math.v3_to_v2(_current_target), 0)
		return
	
	var movement_direction = movement_separation.normalized()

	_velocity_component.set_direction(movement_direction)
	
	_velocity_component.move_basic(_active_aoe, delta)

func has_reached_location(at_location_dist2:float) -> bool:
	if !_active_aoe: return false
	return Math.v3_to_v2(_current_target - _active_aoe.global_position).length_squared() <= at_location_dist2

func _on_request_attack(target:Unit, me:Unit):
	#lock target
	_current_target = target.global_position
	_current_target_enemy = target.is_enemy

func _on_begin_channeling():
	if aoe_scene == null || _active_aoe: return
	
	super._on_begin_channeling()
	
	#spawn aoe
	_active_aoe = (aoe_scene.instantiate() as AreaOfEffect)
	_active_aoe.callback = _on_hit_landed
	_active_aoe.infinite = true
	get_tree().root.add_child(_active_aoe)
	_active_aoe.global_position = Math.v2_to_v3(Math.v3_to_v2(aoe_spawn_point.global_position), 0.75)
	_velocity_component = _active_aoe.find_child("VelocityComponent")

func _on_tree_exiting():
	#clean up aoe
	if is_instance_valid(_active_aoe): _active_aoe.delayed_queue_free()

func _on_end_channeling():
	super._on_end_channeling()
	#clean up aoe
	if is_instance_valid(_active_aoe): _active_aoe.delayed_queue_free()

func _on_hit_landed(enemy:Unit, aoe:AreaOfEffect):
	if !is_instance_valid(enemy): return
	
	var hit_data = create_hit.execute([enemy, Weapon.HitCreationData.new(aoe.global_position)])
	enemy.take_hit(hit_data)
	on_hit_landed.emit(hit_data)
