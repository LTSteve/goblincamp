extends CardModifier

class IceImpEffect extends Effect:
	var _params
	var _velocity_component: VelocityComponent
	var _current_rank
	var _imps = []
	
	func _init(effected_unit:Unit, params, current_rank, imp_id):
		super(effected_unit, params.duration, false, "IceImpEffect")
		
		_params = params
		_current_rank = current_rank
		_imps = [imp_id]
		
		_velocity_component = unit.find_child("VelocityComponent") as VelocityComponent
	
	func on_apply():
		if !is_instance_valid(_velocity_component) || _velocity_component.get_max_speed.has_override([id, "_get_max_speed_override"]): return
		
		unit.add_state(Unit.State.CHILLED)
		
		_velocity_component.get_max_speed.add_override([id, "_get_max_speed_override"],_get_max_speed_override)
	
	func _get_max_speed_override(_base_max_speed:float, current_max_speed:float):
		var stack_level = min(_imps.size(), _params.stacks)
		print((_current_rank * _params.slow_per_rank * stack_level))
		return clampf(current_max_speed - (_current_rank * _params.slow_per_rank * stack_level), 0.01, _base_max_speed)
	
	func on_remove():
		if !is_instance_valid(_velocity_component): return
		
		unit.remove_state(Unit.State.CHILLED)
		
		_velocity_component.get_max_speed.remove_override([id, "_get_max_speed_override"])
	
	func replace_with(effect:Effect):
		var imp_id = effect._imps[0]
		if !_imps.has(imp_id):
			_imps.append(imp_id)
		
		_current_rank = (effect as IceImpEffect)._current_rank
		duration = effect.duration

var aoe_scene

func _initialize(_data):
	aoe_scene = DB.I.scenes.aoe_scene

func _apply(_weapon,unit:Unit):
	var aoe = aoe_scene.instantiate() as AreaOfEffect
	aoe.players = true
	aoe.infinite = true
	aoe.interval = params.check_time
	aoe.radius = params.radius
	aoe.callback = _on_hit_enemy.bind(UniqueMetaId.create([unit]))
	unit.add_child(aoe)
	aoe.global_position = Vector3(unit.global_position.x,0.5,unit.global_position.z)
	UniqueMetaId.store([unit, self, "aoe"], aoe)

func _un_apply(_weapon,unit:Unit):
	var aoe = UniqueMetaId.retrieve([unit, self, "aoe"])
	aoe.queue_free()

func _on_hit_enemy(enemy:Unit, _aoe:AreaOfEffect, imp_id):
	var effect = IceImpEffect.new(enemy, params, current_rank, imp_id)
	
	enemy.add_effect(effect)
