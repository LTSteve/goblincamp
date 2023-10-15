extends Node3D

class_name DamageNumberComponent

var settings: DamageLabelSettingsResource = preload("res://units/components/damagelabel/damage_label_settings.tres")
@export var damage_label_scene: PackedScene
@export var is_ally: bool

static var _my_numbers: Array[DamageLabel] = []

func _on_damage_recieved(weapon_hit:Weapon.Hit):
	if weapon_hit.damage == 0: return
	
	var damage_label = damage_label_scene.instantiate() as DamageLabel
	damage_label.damage = (weapon_hit.post_crit_damage) as int
	damage_label.damage_type = weapon_hit.damage_type
	damage_label.is_crit = weapon_hit.crit
	damage_label.is_ally = is_ally
	$"/root/World".add_child(damage_label)
	damage_label.global_position = global_position
	
	_apply_target_position(damage_label)
	
	_my_numbers.append(damage_label)
	damage_label.tree_exiting.connect(func(): _remove_from_my_numbers(damage_label))

func _remove_from_my_numbers(damage_label):
	var index = _my_numbers.find(damage_label)
	if index == -1: return
	_my_numbers.remove_at(index)

func _apply_target_position(damage_label:DamageLabel):
	var nearby_count = 1
	var my_position:Vector3 = damage_label.global_position
	
	for other in _my_numbers:
		if !is_instance_valid(other): continue
		var other_position = other.global_position + other.new_target_position
		var dist2 = other_position.distance_squared_to(my_position)
		if dist2 > settings.maximum_dist2: continue
		
		var dist_scale = 1 - (dist2 / settings.maximum_dist2)
		var direction = Vector3.UP if dist2 == 0 else (my_position - other_position).normalized()
		damage_label.new_target_position = clampf(dist_scale * settings.push_factor, 0, settings.push_max) * direction
		nearby_count += 1
	
	damage_label.new_target_position /= nearby_count
