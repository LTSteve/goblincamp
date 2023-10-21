extends CardModifier

func _apply(velocity_component,_unit):
	velocity_component.get_max_speed.add_override([velocity_component, self, "_get_max_speed_override"], _get_max_speed_override)
	velocity_component.get_acceleration.add_override([velocity_component, self, "_get_acceleration_override"], _get_acceleration_override)

func _un_apply(velocity_component,_unit):
	velocity_component.get_max_speed.remove_override([velocity_component, self, "_get_max_speed_override"])
	velocity_component.get_acceleration.remove_override([velocity_component, self, "_get_acceleration_override"])

func _get_max_speed_override(base_value:float, current_value:float):
	return current_value + (base_value * params.speed_per_rank * current_rank)

func _get_acceleration_override(base_value:float, current_value:float):
	return current_value + (base_value * params.acceleration_per_rank * current_rank)
