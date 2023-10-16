extends CardModifier

func _apply(weapon,_unit):
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override)

func _un_apply(weapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	if current_value.hit.has_state(Unit.State.CHILLED):
		current_value.crit_chance += params.crit_per_rank * current_rank
	return current_value
