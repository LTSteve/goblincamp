extends CardModifier

func _apply(weapon:Weapon,unit:Unit):
	var rank_component = unit.find_child("RankComponent")
	if !rank_component: return
	
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override.bind(rank_component))

func _un_apply(weapon:Weapon,unit:Unit):
	var rank_component = unit.find_child("RankComponent")
	if !rank_component: return
	
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit,rank_component:RankComponent):
	current_value.damage += base_value.damage * rank_component.get_rank() * params.damage_per_rank * current_rank
	return current_value
