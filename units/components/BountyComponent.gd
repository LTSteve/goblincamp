extends Node3D

class_name BountyComponent

@export var enabled: bool = false
@export var worth_base: int = 100
@export var worth_varience: int = 20

@export var damage_number_resource: PackedScene

@export var sfx_resource: SFXResource

var _num_killed:int = 0

func _on_health_component_died():
	if !enabled: return
	var is_crit = randf() < (_num_killed * 0.15)
	
	var worth = worth_base + randi_range(-worth_varience, worth_varience)
	if is_crit:
		worth = worth * 2
	MoneyManager.I.add_money(worth)
	
	var damage_label = damage_number_resource.instantiate() as DamageLabel
	damage_label.damage = worth
	damage_label.damage_type = Damage.Type.Heal
	damage_label.audio_stream = sfx_resource.bounty_sounds[randi_range(0,sfx_resource.bounty_sounds.size() - 1)]
	damage_label.is_crit = is_crit
	$"/root/World".add_child(damage_label)
	damage_label.global_position = global_position


func _on_unit_on_get_kill(_value):
	_num_killed += 1
