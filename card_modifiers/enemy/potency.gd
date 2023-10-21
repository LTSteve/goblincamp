extends CardModifier

func _apply(node,_unit):
	if node is Weapon:
		node.create_hit.add_override([node, self, "_create_hit_override"],_create_hit_override)
	if node is ArmorComponent:
		node.apply_to_hit.add_override([node, self, "_apply_to_hit_override"], _apply_to_hit_override)

func _un_apply(node,_unit):
	if node is Weapon:
		node.create_hit.remove_override([node, self, "_create_hit_override"])
	if node is ArmorComponent:
		node.apply_to_hit.remove_override([node, self, "_apply_to_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage += base_value.damage * params.damage_increase_percent * current_rank
	return current_value

func _apply_to_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.flat_armor = current_value.flat_armor + params.flat_armor_per_rank * current_rank
	return current_value
