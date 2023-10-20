extends Weapon

class_name RangedWeapon

@export var projectile_scene: PackedScene
@export var projectile_spawn_point: Node3D

@export var dumb_projectile: bool = false

var _current_target:Unit

var _target_collision_layer_hack

func _on_request_attack(target:Unit, me:Unit):
	if ! _try_to_attack(target, me): return
	
	#lock target
	_current_target = target
	_target_collision_layer_hack = target.collision_layer

# spawn projectile
func _on_spawn_projectile():
	var projectile = projectile_scene.instantiate() as Projectile
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn_point.global_position
	
	if _current_target && is_instance_valid(_current_target):
		if dumb_projectile:
			projectile.direction = Math.v3_to_v2(Math.unit_v3(_current_target.global_position - global_position))
		else:
			projectile.target = _current_target
	else:
		# forward i think?
		projectile.direction = Math.v3_to_v2(global_transform.basis.x)
	
	#assign collision mask of hitboxes
	for area in projectile.collision_areas:
		area.collision_mask = _target_collision_layer_hack
		area.body_entered.connect(func(enemy): _on_area_3d_body_entered(enemy, projectile))

# weapon hit enemy
func _on_area_3d_body_entered(enemy, projectile:Projectile):
	if !(enemy is Unit): return
	
	var hit_data = create_hit.execute([enemy, Weapon.HitCreationData.new(projectile.hit_spot.global_position)])
	enemy.take_hit(hit_data)
	on_hit_landed.emit(hit_data)
