extends Weapon

class_name RangedWeapon

@export var projectile_scene: PackedScene
@export var projectile_spawn_point: Node3D

@export var dumb_projectile: bool = false

@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

var _current_target:Unit
var _target_collision_layer_hack
var _current_target_enemy: bool

func _on_request_attack(target:Unit, me:Unit):
	if ! _try_to_attack(target, me): return
	
	#lock target
	_current_target = target
	_target_collision_layer_hack = target.collision_layer
	_current_target_enemy = target.is_enemy

# spawn projectile
func _on_spawn_projectile():
	var projectile = projectile_scene.instantiate() as Projectile
	
	if is_instance_valid(_current_target):
		var target_position = _current_target.global_position + Math.v2_to_v3(Math.rand_v2_range(0, _current_target.ranged_targeting_radius))
		projectile.direction = Math.v3_to_v2((target_position - projectile_spawn_point.global_position).normalized())
	else:
		# forward i think?
		projectile.direction = Math.v3_to_v2(global_transform.basis.x)
	
	if !dumb_projectile:
		projectile.find_new_targets = true
		projectile.find_pool = enemies_resource.value if _current_target_enemy else players_resource.value
		if is_instance_valid(_current_target):
			projectile.target = _current_target
	
	get_tree().root.add_child(projectile)
	projectile.global_position = projectile_spawn_point.global_position
	
	projectile._try_look_in_direction(projectile.direction)
	
	#assign collision mask of hitboxes
	projectile.collision_mask = _target_collision_layer_hack
	projectile.area_entered.connect(_on_area_3d_body_entered.bind(projectile))

# weapon hit enemy
func _on_area_3d_body_entered(enemy, projectile:Projectile):
	if !is_instance_valid(enemy) || !(enemy is Unit) || !is_inside_tree(): return
	
	var hit_data = create_hit.execute([enemy, Weapon.HitCreationData.new(projectile.hit_spot.global_position)])
	enemy.take_hit(hit_data)
	on_hit_landed.emit(hit_data)
