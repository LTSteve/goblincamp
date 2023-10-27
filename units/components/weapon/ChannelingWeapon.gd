extends Weapon

class_name ChannelingWeapon

@export var aoe_scene: PackedScene
@export var aoe_spawn_point: Node3D

var _current_target:Unit
var _target_collision_layer_hack
var _current_target_enemy: bool
var _active_aoe: AreaOfEffect

func _on_begin_channeling():
	#spawn aoe
	if aoe_scene == null: return
	_active_aoe = (aoe_scene.instantiate() as AreaOfEffect)
	_active_aoe.callback = _on_hit_landed
	_active_aoe.infinite = true
	$"/root/World".add_child(_active_aoe)
	_active_aoe.global_position = Math.v2_to_v3(Math.v3_to_v2(aoe_spawn_point.global_position), aoe_spawn_point.position.y)

func _on_end_channeling():
	super._on_end_channeling()
	#clean up aoe
	if is_instance_valid(_active_aoe): _active_aoe.queue_free()

func _on_hit_landed(enemy:Unit, aoe:AreaOfEffect):
	if !is_instance_valid(enemy): return
	
	var hit_data = create_hit.execute([enemy, Weapon.HitCreationData.new(aoe.global_position)])
	enemy.take_hit(hit_data)
	on_hit_landed.emit(hit_data)
