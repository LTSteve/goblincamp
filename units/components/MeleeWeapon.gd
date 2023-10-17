extends Node3D

class_name MeleeWeapon

signal on_get_kill(value: float)
signal on_hit_landed(weapon_hit:Weapon.Hit)

@export var animation_tree: AnimationTreeExpressionExtension

@export var collision_areas: Array[Area3D]
@export var hit_spot: Node3D

@export var weapon_range: float = 3.0
@export var damage: float = 10.0
@export var pushback: float = 5.0
@export var hit_stun: float = 0.5
@export var crit_chance: float = 0.01
@export var crit_damage_multiplier: float = 1.5
@export var damage_type: Damage.Type = Damage.Type.Basic

@export var animation_delay: float = 0
@export var disabled = false

var create_hit = CallableStack.new(Weapon._create_hit)

@export var multi_target: bool = false

var _already_hit:Array[Unit] = []
var _current_pushback_scale: float = 1.0

func _ready():
	for area in collision_areas:
		area.body_entered.connect(_on_area_3d_body_entered)

func _on_enter_combat():
	Weapon._on_enter_combat(self)

func _on_exit_combat():
	Weapon._on_exit_combat(self)

func _on_request_attack(target:Unit, me:Unit):
	if ! Weapon._try_to_attack(self, target, me): return
	
	#reset already hit tracker
	_clear_already_hit()
	
	#assign collision mask of hitboxes
	for area in collision_areas:
		area.collision_mask = target.collision_layer

func _set_pushback_scale(value: float):
	_current_pushback_scale = value

func _clear_already_hit():
	_already_hit = []

# weapon hit enemy
func _on_area_3d_body_entered(unit):
	if !(unit is Unit): return
	#track already hit
	if multi_target:
		if _already_hit.has(unit): return
		_already_hit.append(unit);
	else:
		if !_already_hit.is_empty(): return
		_already_hit.append(unit);
	
	var hit_data = create_hit.execute([self, unit, Weapon.HitCreationData.new(hit_spot.global_position)])
	hit_data.pushback *= _current_pushback_scale
	unit.take_hit(hit_data)
	on_hit_landed.emit(hit_data)

# called from Unit
func scored_kill(value: float):
	on_get_kill.emit(value)
