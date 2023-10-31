extends CardModifier

var explosion_scene: PackedScene
var explosion_radius_squared: float

func _initialize(_data):
	explosion_radius_squared = params.explosion_radius * params.explosion_radius
	explosion_scene = DB.I.explosion_scene

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
	var scale = (1.0 - (explosion.global_position.distance_squared_to(enemy.global_position) / explosion_radius_squared))
	var scale2 = scale * scale
	var explosion_hit = Weapon.Hit.new()
	explosion_hit.direction = Math.unit_v2(Math.v3_to_v2(enemy.global_position-explosion.global_position))
	explosion_hit.is_crit = original_hit.is_crit
	explosion_hit.crit_damage_multiplier = original_hit.crit_damage_multiplier
	explosion_hit.damage = max(1, original_hit.damage * scale2)
	explosion_hit.pushback = max(0.1, original_hit.pushback * scale2)
	explosion_hit.hit_stun = max(0.1, original_hit.hit_stun * scale2)
	explosion_hit.damage_type = original_hit.damage_type
	explosion_hit.hit_by = original_hit.hit_by
	explosion_hit.hit = enemy
	for effect in original_hit.apply_effects:
		explosion_hit.apply_effects.append(effect.duplicate(enemy))
	explosion_hit.hit_creation_data = Weapon.HitCreationData.new(explosion.global_position)
	enemy.take_hit(explosion_hit)
