extends CardModifier

var ember_scene: PackedScene = preload("res://units/weapons/projectiles/ember.tscn")

func _initialize(_data):
	#todo, this won't work so preload it somewhere else so we don't have to hard-code in the file
	pass#ember_scene = load(data.ember_scene_reference)

func _apply(weapon:RangedWeapon,_unit):
	#add with high priority so all damage calculations take place first
	UniqueMetaId.store([weapon, self, "_create_hit_override"], weapon.create_hit.add_override(_create_hit_override, 1000))

func _un_apply(weapon:RangedWeapon,_unit):
	weapon.create_hit.remove_override(UniqueMetaId.retrieve([weapon, self, "_create_hit_override"]))

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	if !current_value.hit_creation_data.can_chain: return current_value
	
	var hit_point = current_value.hit_creation_data.hit_point
	
	var enemies = Global.get_all_units_near_position(
		Global.enemies, 
		Vector3(hit_point.x, 1, hit_point.z), 
		params.ember_scan_radius
		).filter(func(enemy:Unit):
			return is_instance_valid(enemy) && enemy != current_value.hit )
	
	for i in min(enemies.size(), current_rank):
		var enemy = enemies[i]
		#spawn projectile
		var projectile = (ember_scene.instantiate() as Projectile)
		projectile.target = enemy
		get_tree().root.add_child(projectile)
		projectile.global_position = hit_point
		
		#assign eol free
		projectile.destination_reached.connect(projectile.queue_free)
	
		#assign collision mask of hitboxes
		for area in projectile.collision_areas:
			area.collision_mask = enemy.collision_layer
			area.body_entered.connect(func(unit): _on_area_3d_body_entered(unit, projectile, enemy, current_value.hit_by))
	
	return current_value

func _on_area_3d_body_entered(enemy:Unit, projectile:Projectile, target:Unit, weapon:RangedWeapon):
	if !is_instance_valid(enemy) || enemy != target: return
	var hit_creation_data = Weapon.HitCreationData.new(projectile.hit_spot.global_position)
	hit_creation_data.can_chain = false
	hit_creation_data.base_damage_scale = params.ember_damage_scale
	hit_creation_data.base_pushback_scale = params.ember_pushback_scale
	var hit_data = weapon.create_hit.execute([weapon, enemy, hit_creation_data])
	enemy.take_hit(hit_data)
	projectile.queue_free()
