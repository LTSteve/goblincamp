extends CardModifier

class ExcitedNewbieEffect extends Effect:
	var velocity_component: VelocityComponent
	var speed_boost: float
	
	func _init(effected_unit:Unit, effect_duration: float, unit_velocity_component, s_boost: float):
		super._init(effected_unit, effect_duration, true, "ExcitedNewbie")
		velocity_component = unit_velocity_component
		speed_boost = s_boost
	
	func on_apply():
		velocity_component.get_max_speed.add_override([self,"_get_max_speed_override"], _get_max_speed_override)
		velocity_component.get_acceleration.add_override([self,"_get_acceleration_override"], _get_acceleration_override)
	
	func on_remove():
		velocity_component.get_max_speed.remove_override([self,"_get_max_speed_override"])
		velocity_component.get_acceleration.remove_override([self,"_get_acceleration_override"])
	
	func _get_max_speed_override(base_value:float, current_value:float):
		return current_value + base_value * speed_boost

	func _get_acceleration_override(base_value:float, current_value:float):
		return current_value + base_value * speed_boost * 2

class Unit_Data:
	var unit: Unit
	var rank_component: RankComponent
	var velocity_component: VelocityComponent
	
	func _init(u,r,v):
		unit = u
		rank_component = r
		velocity_component = v

var rookies:Array[Unit_Data] = []

func _initialize(_data):
	DB.I.observables.is_day.value_changed.connect(_on_day)

func _apply(rank_component:RankComponent, unit:Unit):
	if rank_component.get_rank() != 0: return
	
	rookies.append(Unit_Data.new(unit, rank_component, unit.find_child("VelocityComponent")))

func _un_apply(_rank_component:RankComponent, unit:Unit):
	_find_and_remove_from_rookie_list(unit)

func _on_day(is_day, _was_day):
	if is_day: return
	if current_rank == 0: return
	
	_maintain_rookie_list()
	
	for rookie in rookies:
		var effect = ExcitedNewbieEffect.new(rookie.unit, params.duration, rookie.velocity_component, current_rank * params.speed_gain_per_rank)
		rookie.unit.add_effect(effect)

func _find_and_remove_from_rookie_list(unit:Unit):
	var index = -1
	for i in rookies.size():
		var rookie = rookies[i]
		if !is_instance_valid(rookie.unit): continue
		if rookie.unit == unit:
			index = i
			break
	
	if index == -1: return
	rookies.remove_at(index)

func _maintain_rookie_list():
	var to_remove = []
	
	for i in rookies.size():
		var rookie = rookies[i]
		if !is_instance_valid(rookie.unit) || (rookie.rank_component && rookie.rank_component.get_rank() != 0):
			to_remove.append(i)
	
	var num_to_remove = to_remove.size()
	
	#remove from end first for efficency
	for i in num_to_remove:
		var index = to_remove[num_to_remove-i-1]
		rookies.remove_at(index)
