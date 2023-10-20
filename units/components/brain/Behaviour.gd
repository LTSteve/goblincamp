extends Resource

class_name Behaviour

func initialize(_brain:BrainComponent):
	return null

func assign_target(_delta, _brain:BrainComponent, _behaviour_data):
	pass

func process(_delta, _brain:BrainComponent, _behaviour_data):
	pass

func _bind_to_all_weapons(brain:BrainComponent) -> Array[Weapon]:
	var all_weps = brain.weapon_holder.find_children("", "Weapon")
	var weapons:Array[Weapon] = []
	for wep in all_weps:
		brain.enter_combat.connect(wep._on_enter_combat)
		brain.exit_combat.connect(wep._on_exit_combat)
		brain.request_attack.connect(wep._on_request_attack)
		weapons.append(wep as Weapon)
	return weapons
