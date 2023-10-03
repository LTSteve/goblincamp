extends CharacterBody3D

class_name Unit

@onready var health_component: HealthComponent = $HealthComponent

@onready var velocity_component: VelocityComponent = $VelocityComponent

@onready var rotation_component: RotationComponent = $RotationComponent

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

@export var is_enemy: bool = false

const MOVEMENT_SPEED: float = 5.0

static var only_created = false
static var only_is_me = false

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	if !only_created:
		only_created = true
		only_is_me = true
	
	if is_enemy: Global.enemies.append(self)
	else: Global.players.append(self)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _on_died():
	if is_enemy: Global.enemies = Global.enemies.filter(func(enemy): return enemy != self)
	else: Global.players = Global.players.filter(func(player): return player != self)
	queue_free()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = Math.v3_to_v2(global_position)
	var next_path_position: Vector2 = Math.v3_to_v2(navigation_agent.get_next_path_position())
	
	var unit_direction = Math.unit(next_path_position - current_agent_position)
	
	if unit_direction == Vector2.ZERO: return
	
	velocity_component.accelerate_in_direction(unit_direction)
	velocity_component.move(self)
	
	rotation_component.turn_to_direction(unit_direction, delta)
	rotation_component.apply_rotation(self)

func take_hit(direction:Vector2, damage:float, pushback:float):
	velocity_component.set_velocity(direction * pushback)
	health_component.damage(damage)
