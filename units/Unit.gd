extends CharacterBody3D

class_name Unit

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var rotation_component: RotationComponent = $RotationComponent
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export var is_enemy: bool = false

signal on_recieved_hit(direction:Vector2, damage:float, pushback:float, hit_stun:float, crit: bool, damage_type: Damage.Type)

var _stunned: float = 0
var _regular_collision: int = 0

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	_regular_collision = collision_layer
	
	if is_enemy: Global.enemies.append(self)
	else: Global.players.append(self)
	
	call_deferred("_apply_unit_modifiers")

func _apply_unit_modifiers():
	#apply modifiers
	ModifierManager.apply_unit_modifiers(self)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _on_died():
	if is_enemy:
		Global.enemies = Global.enemies.filter(func(enemy): return enemy != self)
		if Global.enemies.size() == 0:
			GameManager.I.cycle_to_day()
	else: Global.players = Global.players.filter(func(player): return player != self)
	queue_free()

func _physics_process(delta):
	_stunned -= delta
	
	collision_shape.disabled = _stunned > 0
	
	if _stunned <= 0 && !navigation_agent.is_navigation_finished():
		var current_agent_position: Vector2 = Math.v3_to_v2(global_position)
		var next_path_position: Vector2 = Math.v3_to_v2(navigation_agent.get_next_path_position())
		
		var unit_direction = Math.unit(next_path_position - current_agent_position)
		
		if unit_direction == Vector2.ZERO: return
		
		velocity_component.accelerate_in_direction(unit_direction, delta)
		rotation_component.turn(unit_direction, self, delta)
	
	velocity_component.move(self)
	rotation_component.apply_rotation(self)

func take_hit(direction:Vector2, damage:float, pushback:float, hit_stun:float, crit:bool = false, damage_type:Damage.Type = Damage.Type.Basic):
	on_recieved_hit.emit(direction, damage, pushback, hit_stun, crit, damage_type)
	_stunned = hit_stun
