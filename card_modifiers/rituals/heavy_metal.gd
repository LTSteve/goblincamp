extends CardModifier

func _apply(weapon:Weapon,_unit):
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override)

func _un_apply(weapon:Weapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.pushback += base_value.pushback * params.pushback_per_rank * current_rank
	return current_value
