extends Node3D

class_name MeleeWeapon

@export var animation_tree: AnimationTreeExpressionExtension

@export var collision_areas: Array[Area3D]


@export var range: float = 3.0
@export var cooldown: float = 0.75
@export var damage: float = 10.0
@export var pushback: float = 5.0

@export var multi_target: bool = false

var _current_cooldown:float = 0.0
var _current_animation:String = "idle"
var _already_hit:Array[Unit] = []

func _ready():
	animation_tree.animation_started.connect(_on_animation_changed)
	for area in collision_areas:
		area.body_entered.connect(_on_area_3d_body_entered)

func _process(delta):
	_current_cooldown -= delta

func _on_animation_changed(next_animation: String):
	_current_animation = next_animation

func _on_enter_combat():
	animation_tree.set("parameters/conditions/in_combat", true)
	animation_tree.set("parameters/conditions/not_in_combat", false)

func _on_exit_combat():
	animation_tree.set("parameters/conditions/in_combat", false)
	animation_tree.set("parameters/conditions/not_in_combat", true)

func _on_request_attack(target:Unit, me:Unit):
	#in range?
	if(_current_cooldown > 0 
	|| (target.global_position - me.global_position).length() > range
	|| (animation_tree.get("parameters/playback").get_current_node() != "idle_combat")) : return
	
	#reset already hit tracker
	_already_hit = []
	
	#assign collision mask of hitboxes
	for area in collision_areas:
		area.collision_mask = target.collision_layer
	
	#trigger animation
	animation_tree.activate_trigger("attack")
	
	#reset cooldown
	_current_cooldown = cooldown

# weapon hit enemy
func _on_area_3d_body_entered(unit:Unit):
	#track already hit
	if multi_target:
		if _already_hit.has(unit): return
		_already_hit.append(unit);
	else:
		if !_already_hit.is_empty(): return
		_already_hit.append(unit);
	
	unit.take_hit(
		Math.unit(Math.v3_to_v2(unit.global_position-global_position)),
		damage, pushback)
