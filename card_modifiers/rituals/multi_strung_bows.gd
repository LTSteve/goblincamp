extends CardModifier

func _apply(node,_unit):
	if node is RangedWeapon:
		node.create_hit.add_override([node, self, "_create_hit_override"], _create_hit_override, 50)
	
	if node is AnimationTreeExpressionExtension:
		node.set_use_attack_2(true)

func _un_apply(node,_unit):
	if node is RangedWeapon:
		node.create_hit.remove_override([node, self, "_create_hit_override"])
	
	if node is AnimationTreeExpressionExtension:
		node.set_use_attack_2(false)

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage *= (params.damage_base_scale + params.damage_scale * current_rank)
	return current_value

