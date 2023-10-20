extends CharacterBody3D

class_name Unit

enum State { CHILLED, BLEEDING, BURNING }

var state_states: Array[State] = []

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var rotation_component: RotationComponent = $RotationComponent
@onready var armor_component: ArmorComponent = get_node_or_null("ArmorComponent")
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@export var is_enemy: bool = false
@export var kill_value: float = 1

signal on_recieved_hit(weapon_hit:Weapon.Hit)
signal on_state_changed(state_states: Array[State])
signal on_get_kill(value: float)

var _stunned: float = 0
var _regular_collision: int = 0
var _active_effects: Array[Effect] = []

var _last_hit_by
var _facing_direction

var _set_movement_target_task: PrioritizedTaskManager.PrioritizedTask

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	
	_regular_collision = collision_layer
	
	if is_enemy: Global.enemies.append(self)
	else: Global.players.append(self)
	Global.total_units += 1
	
	call_deferred("_apply_unit_modifiers")

func _apply_unit_modifiers():
	#apply modifiers
	ModifierManager.apply_unit_modifiers(self)

func set_movement_target(movement_target: Vector3):
	if !_set_movement_target_task || _set_movement_target_task.done:
		_set_movement_target_task = PrioritizedTaskManager.add_medium_priority_task(func():
			navigation_agent.set_target_position(movement_target)
			, self)

func _on_died():
	if is_enemy:
		Global.enemies = Global.enemies.filter(func(enemy): return enemy != self)
		if Global.enemies.size() == 0:
			GameManager.I.cycle_to_day()
	else: 
		Global.players = Global.players.filter(func(player): return player != self)
	
	Global.total_units -= 1
	
	if is_instance_valid(_last_hit_by) && is_instance_valid(_last_hit_by.unit):
		_last_hit_by.unit.on_get_kill.emit(kill_value)
	for effect in _active_effects:
		effect.on_remove()
	queue_free()

func _process(delta):
	_stunned -= delta
	var effects_count = _active_effects.size()
	for i in range(0,effects_count):
		var effect = _active_effects[(effects_count - 1) - i]
		effect.update(delta)

func do_move(delta):
	if _stunned <= 0 && !navigation_agent.is_navigation_finished():
		var current_agent_position: Vector2 = Math.v3_to_v2(global_position)
		var next_path_position: Vector2 = Math.v3_to_v2(navigation_agent.get_next_path_position())
		
		_facing_direction = Math.unit(next_path_position - current_agent_position)
		
		if _facing_direction == Vector2.ZERO:
			velocity_component.decelerate(delta)
			return
		
		velocity_component.accelerate_in_direction(_facing_direction, delta)
		rotation_component.turn(_facing_direction, self, delta)
	else:
		rotation_component.turn(_facing_direction, self, delta)
		velocity_component.decelerate(delta)
	
	rotation_component.apply_rotation(self)
	velocity_component.move(self)

func take_hit(weapon_hit:Weapon.Hit):
	#calculate crits and armor now after all other calculations
	weapon_hit.is_crit = weapon_hit.is_crit || (randf_range(0,.999) < weapon_hit.crit_chance)
	if(armor_component):
		weapon_hit = armor_component.apply_to_hit.execute([weapon_hit])
	
	for effect in weapon_hit.apply_effects:
		add_effect(effect)
	
	_last_hit_by = weapon_hit.hit_by
	_stunned = max(_stunned, weapon_hit.hit_stun)
	on_recieved_hit.emit(weapon_hit)

func remove_effect(effect:Effect):
	_active_effects.remove_at(_active_effects.find(effect))
	effect.on_remove()

func add_effect(effect:Effect):
	if !effect.try_replace_existing(_active_effects):
		_active_effects.append(effect)
		effect.on_apply()

func add_state(state:State):
	var index = state_states.find(state)
	if index == -1: state_states.append(state)
	on_state_changed.emit(state_states)

func remove_state(state:State):
	var index = state_states.find(state)
	if index != -1: state_states.remove_at(index)
	on_state_changed.emit(state_states)

func has_state(state:State):
	var index = state_states.find(state)
	return index != -1
