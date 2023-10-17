extends CardModifier

func _apply(weapon,_unit):
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override)

func _un_apply(weapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.crit_damage_multiplier += base_value.crit_damage_per_rank * params.crit_damage_per_rank * current_rank
	return current_value
