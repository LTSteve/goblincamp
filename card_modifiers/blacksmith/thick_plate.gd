extends CardModifier

func _apply(armor,_unit):
	armor.apply_to_hit.add_override([armor, self, "_apply_to_hit_override"], _apply_to_hit_override)

func _un_apply(armor,_unit):
	armor.apply_to_hit.remove_override([armor, self, "_apply_to_hit_override"])

func _apply_to_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.flat_armor = current_value.flat_armor + params.flat_armor_per_rank * current_rank
	return current_value
