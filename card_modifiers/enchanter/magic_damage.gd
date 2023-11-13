extends CardModifier

func _apply(weapon,_unit):
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override)

func _un_apply(weapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage += base_value.damage * params.percent
	return current_value
