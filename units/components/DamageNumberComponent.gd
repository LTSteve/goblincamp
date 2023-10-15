extends Node3D

class_name DamageNumberComponent

@export var damage_label_scene: PackedScene
@export var is_ally: bool

func _on_damage_recieved(weapon_hit:Weapon.Hit):
	if weapon_hit.damage == 0: return
	
	var damage_label = damage_label_scene.instantiate() as DamageLabel
	damage_label.damage = (weapon_hit.post_crit_damage) as int
	damage_label.damage_type = weapon_hit.damage_type
	damage_label.is_crit = weapon_hit.crit
	damage_label.is_ally = is_ally
	$"/root/World".add_child(damage_label)
	damage_label.global_position = global_position
