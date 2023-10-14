extends CardModifier

func _apply(weapon,_unit):
	UniqueMetaId.store([weapon, self, "_create_hit_override"], weapon.create_hit.add_override(_create_hit_override))

func _un_apply(weapon,_unit):
	weapon.create_hit.remove_override(UniqueMetaId.retrieve([weapon, self, "_create_hit_override"]))

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit, _weapon, _target:Unit):
	current_value.damage += base_value.damage * params.damage_increase_percent * current_rank
	return current_value
