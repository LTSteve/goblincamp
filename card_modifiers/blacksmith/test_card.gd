extends CardModifier

func _initialize(_data):
	pass

func _apply(node):
	if node is MeleeWeapon:
		_apply_weapon(node)

func _apply_weapon(weapon:MeleeWeapon):
	weapon.damage *= 10 * current_rank
