extends CardModifier

func _apply(weapon:MeleeWeapon,_unit:Unit):
	#make sure this override happens near the end to get full damage calculations
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override, 1000)

func _un_apply(weapon:MeleeWeapon,_unit:Unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	#apply effect to weapon_hit.unit
	if current_value.damage > 0:
		var effect = DamageOverTimeEffect.new(current_value.hit, 
		current_value.hit_by, 
		current_value.post_crit_damage / 10.0, 
		params.stack_limit_per_rank * current_rank,
		params.duration,
		params.tick_time,
		UniqueMetaId.create([self]),
		Damage.Type.Bleed,
		Unit.State.BLEEDING)
		current_value.hit.add_effect(effect)
	return current_value
