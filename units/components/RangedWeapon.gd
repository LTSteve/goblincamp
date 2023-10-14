extends Node3D

class_name RangedWeapon

signal on_get_kill(value: float)
signal on_hit_landed(weapon_hit:Weapon.Hit)

@export var animation_tree: AnimationTreeExpressionExtension
@export var projectile_scene: PackedScene
@export var projectile_spawn_point: Node3D

@export var weapon_range: float = 20.0
@export var cooldown: float = 2
@export var damage: float = 30.0
@export var pushback: float = 7.0
@export var hit_stun: float = 0.7
@export var crit_chance: float = 0.01
@export var crit_damage_multiplier: float = 1.5
@export var dumb_projectile: bool = false
@export var damage_type: Damage.Type = Damage.Type.Basic

var create_hit = CallableStack.new(Weapon._create_hit)

var current_cooldown:float = 0.0
var _current_target:Unit

var _target_collision_layer_hack

func _process(delta):
	Weapon._process(self, delta)

func _on_enter_combat():
	animation_tree.set("parameters/conditions/in_combat", true)
	animation_tree.set("parameters/conditions/not_in_combat", false)

func _on_exit_combat():
	animation_tree.set("parameters/conditions/in_combat", false)
	animation_tree.set("parameters/conditions/not_in_combat", true)

func _on_request_attack(target:Unit, me:Unit):
	if ! Weapon._try_to_attack(self, target, me): return
	
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
			projectile.direction = Math.v3_to_v2(Math.unit(_current_target.global_position - global_position))
		else:
			projectile.target = _current_target
	else:
		# forward i think?
		projectile.direction = Math.v3_to_v2(global_transform.basis.x)
	
	#assign collision mask of hitboxes
	for area in projectile.collision_areas:
		area.collision_mask = _target_collision_layer_hack
		area.body_entered.connect(_on_area_3d_body_entered)

# weapon hit enemy
func _on_area_3d_body_entered(unit):
	if !(unit is Unit): return
	
	var hit_data = create_hit.execute([self, unit])
	unit.take_hit(hit_data)
	on_hit_landed.emit(hit_data)

# called from Unit
func scored_kill(value: float):
	on_get_kill.emit(value)
