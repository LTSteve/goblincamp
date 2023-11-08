extends CardModifier

func _apply(weapon,_unit:Unit):
	match current_rank:
		1:
			if weapon is MeleeWeapon || weapon.is_in_group("Bow"): return
			_apply_to(weapon)
		2:
			if weapon is MeleeWeapon: return
			_apply_to(weapon)
		3:
			_apply_to(weapon)

func _apply_to(weapon):
	#after crit_chance is applied
	weapon.create_hit.add_override([weapon,self,"_create_hit_override"], _create_hit_override, 50)

func _un_apply(weapon,_unit:Unit):
	weapon.create_hit.remove_override([weapon,self,"_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	var effect = BurnEffect.new(current_value.hit,
	current_value.hit_by,
	params.damage)
	
	current_value.apply_effects.append(effect)
	
	return current_value
