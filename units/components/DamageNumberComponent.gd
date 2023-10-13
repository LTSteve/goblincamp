extends Node3D

class_name DamageNumberComponent

@export var damage_label_scene: PackedScene
@export var is_ally: bool

func _on_damage_recieved(_direction:Vector2, damage:float, _pushback:float, _hit_stun:float, crit: bool, damage_type: Damage.Type):
	var damage_label = damage_label_scene.instantiate() as DamageLabel
	damage_label.damage = damage as int
	damage_label.damage_type = damage_type
	damage_label.is_crit = crit
	damage_label.is_ally = is_ally
	add_child(damage_label)
