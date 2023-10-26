extends CharacterBody3D

class_name Unit

enum State { NORMAL, CHILLED, BLEEDING, BURNING, ENRAGED, SLEEPING }

var state_states: Array[State] = []

var cardinal_claims: Array[bool] = [false, false, false, false, false, false, false, false]

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var rotation_component: RotationComponent = $RotationComponent
@onready var armor_component: ArmorComponent = get_node_or_null("ArmorComponent")
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var pathfinder_component: PathfinderComponent = $PathfinderComponent

@export var ranged_targeting_radius: float = 1

@export var is_enemy: bool = false
@export var kill_value: float = 1

signal on_recieved_hit(weapon_hit:Weapon.Hit)
signal on_state_changed(state_states: Array[State])
signal on_get_kill(value: float)

var _stunned: float = 0
var _regular_collision: int = 0
var _active_effects: Array[Effect] = []

var _last_hit_by
var _facing_direction = Vector2.ZERO

var _set_movement_target_task: PrioritizedTaskManager.PrioritizedTask

func _ready():
	_regular_collision = collision_layer
	
	if is_enemy: Global.enemies.append(self)
	else: Global.players.append(self)
	
	call_deferred("_apply_unit_modifiers")

func _apply_unit_modifiers():
	#apply modifiers
	ModifierManager.apply_unit_modifiers(self)

func set_movement_target(movement_target: Vector3, speed_scale: float = 1.0):
	if !_set_movement_target_task || _set_movement_target_task.done:
		_set_movement_target_task = PrioritizedTaskManager.add_medium_priority_task(func():
			velocity_component.speed_scale = speed_scale
			pathfinder_component.find_new_path(movement_target)
			, self)

func _on_died():
	if is_enemy:
		Global.enemies = Global.enemies.filter(func(enemy): return enemy != self)
		if Global.enemies.size() == 0:
			GameManager.I.cycle_to_day()
	else: 
		Global.players = Global.players.filter(func(player): return player != self)
		if Global.players.size() == 0:
			GameManager.I.game_over()
	
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
	var movement_direction = pathfinder_component.get_next_direction() if _stunned <= 0 else Vector2.ZERO
	_facing_direction = movement_direction if movement_direction != Vector2.ZERO else _facing_direction
	
	velocity_component.accelerate_in_direction(movement_direction, delta)
	rotation_component.turn(_facing_direction, self, delta)
	
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
	if state == State.NORMAL: return
	var index = state_states.find(state)
	if index == -1: state_states.append(state)
	on_state_changed.emit(state_states)

func remove_state(state:State):
	if state == State.NORMAL: return
	var index = state_states.find(state)
	if index != -1: state_states.remove_at(index)
	on_state_changed.emit(state_states)

func has_state(state:State):
	if state == State.NORMAL: return true
	var index = state_states.find(state)
	return index != -1

func claim_unit(claimer_position: Vector3):
	var nearest_cardinals = Math.nearest_cardinals(Math.v3_to_v2(claimer_position), Math.v3_to_v2(self.global_position))
	#find and claim nearest possible cardinal
	for cardinal in nearest_cardinals:
		if !cardinal_claims[cardinal]:
			cardinal_claims[cardinal] = true
			return cardinal
	return null

func un_claim_unit(cardinal: Math.Cardinal):
	cardinal_claims[cardinal] = false
