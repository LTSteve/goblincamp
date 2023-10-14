extends Node3D

class_name DamageNumberComponent

@export var damage_label_scene: PackedScene
@export var is_ally: bool

func _on_damage_recieved(weapon_hit:Weapon.Hit):
	var damage_label = damage_label_scene.instantiate() as DamageLabel
	damage_label.damage = weapon_hit.damage as int
	damage_label.damage_type = weapon_hit.damage_type
	damage_label.is_crit = weapon_hit.crit
	damage_label.is_ally = is_ally
	add_child(damage_label)
