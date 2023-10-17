extends Effect

class_name DamageOverTimeEffect

var _total_damage: int
var _my_damage: int
var _remaining_damage: int
var _tick_time: float
var _applier #MeleeWeapon or RangedWeapon
var _base_tick_damage: int
var _remaining_ticks: int
var _current_tick_cooldown: float
var _damage_type: Damage.Type
var _apply_state: Unit.State

var _stack_limit: int
var stack = []

func _init(effected_unit:Unit, applier, damage: float, stack_limit: int, effect_duration: float, effect_tick_time: float, effect_id: String, damage_type:Damage.Type, apply_state: Unit.State):
	super._init(effected_unit, effect_duration, damage <= 0, effect_id)
	
	_applier = applier
	_tick_time = effect_tick_time
	_current_tick_cooldown = _tick_time
	_damage_type = damage_type
	_apply_state = apply_state
	
	stack.append(self)
	
	_stack_limit = stack_limit
	_my_damage = floor(damage)
	_total_damage = _my_damage
	
	_calculate_remaining_damage()

func on_apply():
	if _apply_state != null:
		unit.add_state(_apply_state)

func on_remove():
	if _apply_state != null:
		unit.remove_state(_apply_state)

func _calculate_remaining_damage():
	_remaining_damage = _total_damage
	_remaining_ticks = floor(duration / _tick_time)
	@warning_ignore("integer_division")
	_base_tick_damage = floor(_total_damage / _remaining_ticks)

func update(delta:float):
	if update_duration_and_return_is_finished(delta): return
	
	_current_tick_cooldown -= delta
	if _current_tick_cooldown > 0: return
	_current_tick_cooldown += _tick_time
	
	var damage = _base_tick_damage if _remaining_damage == (_base_tick_damage * _remaining_ticks) else (_base_tick_damage + 1)
	_remaining_damage -= damage
	_remaining_ticks -= 1
	
	var hit_data = Weapon.Hit.new()
	hit_data.damage = damage
	hit_data.hit_stun = 0
	hit_data.damage_type = _damage_type
	hit_data.hit_by = _applier if is_instance_valid(_applier) else null 
	hit_data.hit = unit
	hit_data.hit_creation_data = Weapon.HitCreationData.new(Vector3(unit.global_position.x,0.5,unit.global_position.z))
	unit.take_hit(hit_data)

func replace_with(effect:Effect):
	#take new effect's duration
	duration = effect.duration
	#take the new effect's applier
	_applier = effect._applier
	
	if _stack_limit > 1:
		#use up a stack
		_stack_limit -= 1
		stack.append(effect)
	else:
		var lowest_damage_stack = null
		var lowest_damage_index = 0
		for i in stack.size():
			if !lowest_damage_stack || lowest_damage_stack._my_damage < stack[i]._my_damage:
				lowest_damage_stack = stack[i]
				lowest_damage_index = i
		if effect._my_damage > lowest_damage_stack._my_damage:
			stack[lowest_damage_index] = effect
	
	_total_damage = 0
	for e in stack:
		#add up the damage
		_total_damage += e._my_damage
	
	#recalc ticks
	_calculate_remaining_damage()
