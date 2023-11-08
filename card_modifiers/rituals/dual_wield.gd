extends CardModifier

func _apply(weapon:MeleeWeapon,_unit:Unit):
	if current_rank == 0: return
	var main_weapon = !weapon.disabled
	
	if !main_weapon:
		#activate side weapon
		weapon.visible = true
		weapon.disabled = false
	
	#mark weapons
	UniqueMetaId.store([weapon, self, "main_weapon"], main_weapon)
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override.bind(main_weapon), 50)

func _un_apply(weapon,_unit:Unit):
	if current_rank == 0: return
	var main_weapon = UniqueMetaId.retrieve([weapon, self, "main_weapon"])
	
	if !main_weapon:
		#deactivate side weapon
		weapon.visible = false
		weapon.disabled = true
	
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit, main_weapon:bool):
	if main_weapon:
		# main weapon hits first, so reverse and scale pushback to keep enemy in range a bit better
		current_value.pushback = -current_value.pushback * params.pushback_scale
	else: #scale damage
		current_value.damage *= params.damage_scale_per_rank * current_rank
	return current_value
