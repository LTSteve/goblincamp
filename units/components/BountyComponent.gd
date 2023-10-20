extends Node3D

class_name BountyComponent

@export var enabled: bool = false
@export var worth_base: int = 100
@export var worth_varience: int = 20

@export var damage_number_resource: PackedScene

@export var sfx_resource: SFXResource

func _on_health_component_died():
	if !enabled: return
	var worth = worth_base + randi_range(-worth_varience, worth_varience)
	MoneyManager.I.add_money(worth)
	
	var damage_label = damage_number_resource.instantiate() as DamageLabel
	damage_label.damage = worth
	damage_label.damage_type = Damage.Type.Heal
	damage_label.audio_stream = sfx_resource.bounty_sounds[randi_range(0,sfx_resource.bounty_sounds.size() - 1)]
	$"/root/World".add_child(damage_label)
	damage_label.global_position = global_position
