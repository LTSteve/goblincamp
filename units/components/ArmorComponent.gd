extends Node

class_name ArmorComponent

@export var armor: int = 0

var apply_to_hit = CallableStack.new(_apply_to_weapon_hit)

func _apply_to_weapon_hit(weapon_hit:Weapon.Hit):
	if weapon_hit.damage <= 1: return
	weapon_hit.flat_armor = armor
	return weapon_hit
