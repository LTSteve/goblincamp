extends CardModifier

func _apply(weapon:Weapon,_unit:Unit):
	#after crit_chance is applied
	weapon.create_hit.add_override([weapon,self,"_create_hit_override"], _create_hit_override, 50)

func _un_apply(weapon,_unit:Unit):
	weapon.create_hit.remove_override([weapon,self,"_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	if !_can_apply(current_value): return current_value
	
	var effect = BurnEffect.new(current_value.hit,
	current_value.hit_by,
	params.damage)
	
	current_value.apply_effects.append(effect)
	
	return current_value

func _can_apply(hit:Weapon.Hit) -> bool:
	if current_rank <= 0: return false
	if hit.damage_type == Damage.Type.Fire: return true
	if current_rank >= 2 && is_instance_valid(hit.hit_by) && hit.hit_by.is_in_group("Magic"): return true
	if current_rank >= 3 && is_instance_valid(hit.hit_by) && hit.hit_by.is_in_group("Martial"): return true
	return false
