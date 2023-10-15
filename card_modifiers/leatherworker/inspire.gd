extends CardModifier

const INSPIRE_RADIUS: float = 20

class InspireEffect extends Effect:
	var weapons_applied_to = []
	
	var params
	var current_rank
	
	func _init(unit_effected: Unit, id_append: String, parameters, rank):
		id = "InspireEffect%s" % id_append
		buff = true
		duration = 10
		unit = unit_effected
		params = parameters
		current_rank = rank
	
	func on_apply():
		weapons_applied_to = unit.find_children("", "MeleeWeapon") + unit.find_children("","RangedWeapon")
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			UniqueMetaId.store([weapon, self, "_create_hit_override"], weapon.create_hit.add_override(_create_hit_override))
	
	func on_remove():
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			weapon.create_hit.remove_override(UniqueMetaId.create([weapon, self, "_create_hit_override"]))
		weapons_applied_to = []
	
	func _create_hit_override(base_value:Weapon.Hit, current_value:Weapon.Hit):
		current_value.damage += base_value.damage * params.damage_increase_percent * current_rank
		return current_value

func _apply(weapon:Node,unit:Unit):
	var _on_get_kill_override = func (_value): _on_get_kill(unit)
	UniqueMetaId.store([weapon, self, "_on_get_kill_override"], _on_get_kill_override)
	weapon.on_get_kill.connect(_on_get_kill_override)

func _un_apply(weapon:Node,_unit:Unit):
	#only need to disconnect if this is the last rank
	if current_rank == 1:
		weapon.on_get_kill.disconnect(UniqueMetaId.create([weapon, self, "_on_get_kill_override"]))

func _on_get_kill(killer:Unit):
	if !is_instance_valid(killer): return
	# do sphere cast for nearby player units
	var nearby_units:Array[Unit] = Global.get_all_units_near_position(Global.players, killer.global_position, INSPIRE_RADIUS)
	# apply an effect to all of them
	for unit in nearby_units:
		var effect = InspireEffect.new(unit, str(killer.get_instance_id()), params, current_rank)
		unit.add_effect(effect)
