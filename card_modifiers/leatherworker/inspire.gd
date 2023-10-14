extends CardModifier

class InspireEffect extends Effect:
	
	var weapons_applied_to = []
	
	func _init(unit_effected: Unit, id_append: String):
		id = "InspireEffect%s" % id_append
		buff = true
		duration = 10
		unit = unit_effected
	
	func on_apply():
		weapons_applied_to = unit.find_children("", "MeleeWeapon") + unit.find_children("","RangedWeapon")
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			weapon.damage_scale_x_100 += 40
	
	func on_remove():
		for weapon in weapons_applied_to:
			if !is_instance_valid(weapon): continue
			weapon.damage_scale_x_100 -= 40
		weapons_applied_to = []
	
	func replace_with(effect:Effect):
		super.replace_with(effect)
		var current_weapons = unit.find_children("", "MeleeWeapon") + unit.find_children("","RangedWeapon")
		
		var applied_exclusive = _get_all_exclusive_elements(weapons_applied_to, current_weapons)
		for weapon in applied_exclusive:
			if !is_instance_valid(weapon): continue
			weapon.damage_scale -= 40
		
		var current_exclusive = _get_all_exclusive_elements(current_weapons, weapons_applied_to)
		for weapon in current_exclusive:
			if !is_instance_valid(weapon): continue
			weapon.damage_scale += 40
		
		weapons_applied_to = current_weapons
	
	func _get_all_exclusive_elements(to:Array,vs:Array):
		var exclusive = []
		for el in to: if !vs.has(el): exclusive.append(el)
		return exclusive
	
	func _get_all_shared_elements(a: Array, b:Array):
		var shared = []
		for el in a: if b.has(el): shared.append(el)
		return shared

const __inspire_on_get_kill: String = "__inspire_on_get_kill"
const INSPIRE_RADIUS: float = 20

func _apply(weapon:Node,unit:Unit):
	weapon.set_meta(__inspire_on_get_kill, func(_value): _on_get_kill(unit))
	weapon.on_get_kill.connect(weapon.get_meta(__inspire_on_get_kill))

func _un_apply(weapon:Node,_unit:Unit):
	#only need to disconnect if this is the last rank
	if current_rank == 1:
		weapon.on_get_kill.disconnect(weapon.get_meta(__inspire_on_get_kill))

func _on_get_kill(killer:Unit):
	if !is_instance_valid(killer): return
	# do sphere cast for nearby player units
	var nearby_units:Array[Unit] = Global.get_all_units_near_position(Global.players, killer.global_position, INSPIRE_RADIUS)
	# apply an effect to all of them
	for unit in nearby_units:
		var effect = InspireEffect.new(unit, str(killer.get_instance_id()))
		unit.add_effect(effect)
