extends CardModifier

var explosion_scene: PackedScene = preload("res://fx/explosion.tscn")

func _initialize(_data):
	#todo, this won't work so preload it somewhere else so we don't have to hard-code in the file
	pass#explosion_scene = load(data.explosion_scene_reference)

func _apply(weapon:RangedWeapon,_unit):
	#add with high priority so all damage calculations take place first
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override, 1000)

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	var aoe = (explosion_scene.instantiate() as AreaOfEffect)
	var cloned_value = current_value.duplicate()
	aoe.callback = func(enemy, explosion): _on_hit_landed(enemy, explosion, cloned_value)
	$"/root/World".add_child(aoe)
	aoe.global_position = Vector3(current_value.hit_creation_data.hit_point.x,0.5,current_value.hit_creation_data.hit_point.z)
	
	# discard actual hit in favor of explosion hit
	current_value.damage = 0
	current_value.hit_stun = 0
	current_value.pushback = 0
	current_value.direction = Vector2.ZERO
	current_value.apply_effects = []
	
	return current_value

func _on_hit_landed(enemy:Unit, explosion:AreaOfEffect, original_hit: Weapon.Hit):
	var explosion_hit = Weapon.Hit.new()
	explosion_hit.direction = Math.unit(Math.v3_to_v2(enemy.global_position-explosion.global_position))
	explosion_hit.is_crit = original_hit.is_crit
	explosion_hit.crit_damage_multiplier = original_hit.crit_damage_multiplier
	explosion_hit.damage = original_hit.damage
	explosion_hit.pushback = original_hit.pushback
	explosion_hit.hit_stun = original_hit.hit_stun
	explosion_hit.damage_type = original_hit.damage_type
	explosion_hit.hit_by = original_hit.hit_by
	explosion_hit.hit = enemy
	for effect in original_hit.apply_effects:
		explosion_hit.apply_effects.append(effect.duplicate(enemy))
	explosion_hit.hit_creation_data = Weapon.HitCreationData.new(explosion.global_position)
	enemy.take_hit(explosion_hit)
