extends CardModifier

var ember_scene: PackedScene = preload("res://units/weapons/projectiles/ember.tscn")

func _initialize(_data):
	#todo, this won't work so preload it somewhere else so we don't have to hard-code in the file
	pass#ember_scene = load(data.ember_scene_reference)

func _apply(weapon:RangedWeapon,_unit):
	#add with high priority so all damage calculations take place first
	weapon.create_hit.add_override([weapon, self, "_create_hit_override"], _create_hit_override, 1000)

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.create_hit.remove_override([weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	if !current_value.hit_creation_data.can_chain: return current_value
	
	var hit_point = current_value.hit_creation_data.hit_point
	
	var all_enemies = Global.get_all_units_near_position(
		Global.enemies, 
		Vector3(hit_point.x, 1, hit_point.z), 
		params.ember_scan_radius
		)
	
	var enemies = all_enemies.filter(func(enemy:Unit):
		return is_instance_valid(enemy) && enemy != current_value.hit )
	
	for i in min(enemies.size(), current_rank):
		var enemy = enemies[i]
		#spawn projectile
		var projectile = (ember_scene.instantiate() as Projectile)
		projectile.target = enemy
		
		#have to do this so the ember won't free itself on hit with enemies that arent the target
		projectile.free_on_hit = false
		projectile.destination_reached.connect(projectile._queue_free_self)
		
		#assign collision mask of hitboxes
		projectile.collision_mask = enemy.collision_layer
		projectile.area_entered.connect(func(unit): 
			if !is_instance_valid(unit) || !is_instance_valid(current_value.hit_by): return
			_on_area_3d_body_entered(unit, projectile, current_value))
		
		get_tree().root.add_child(projectile)
		projectile.global_position = hit_point
	
	return current_value

func _on_area_3d_body_entered(enemy:Unit, projectile:Projectile, original_hit: Weapon.Hit):
	if !is_instance_valid(enemy) || enemy != projectile.target: return
	var hit_creation_data = Weapon.HitCreationData.new(projectile.hit_spot.global_position)
	hit_creation_data.can_chain = false
	hit_creation_data.base_damage_scale = params.ember_damage_scale
	hit_creation_data.base_pushback_scale = params.ember_pushback_scale
	hit_creation_data.can_crit = false
	for effect in original_hit.apply_effects:
		hit_creation_data.apply_effects.append(effect.duplicate(enemy))
	var hit_data = original_hit.hit_by.create_hit.execute([enemy, hit_creation_data])
	enemy.take_hit(hit_data)
	projectile._queue_free_self()
