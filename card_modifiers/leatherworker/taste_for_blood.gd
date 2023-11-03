extends CardModifier

var taste_for_blood_scene

func _initialize(_data):
	taste_for_blood_scene = DB.I.scenes.taste_for_blood_scene

func _apply(_node,unit):
	unit.on_recieved_hit.connect(_on_recieved_hit)

func _un_apply(_node,unit):
	unit.on_recieved_hit.disconnect(_on_recieved_hit)

func _on_recieved_hit(hit:Weapon.Hit):
	#don't trigger on heals
	if hit.damage <= 0: return
	
	var aoe = (taste_for_blood_scene.instantiate() as AreaOfEffect)
	var heal_value = params.hp_for_bleed if hit.damage_type == Damage.Type.Bleed else params.hp_for_damage
	
	aoe.players = true
	aoe.radius = params.nearby_radius
	aoe.callback = _on_player_found.bind(heal_value)
	aoe.lifespan = 0
	$"/root/World".add_child(aoe)
	aoe.global_position = Vector3(hit.hit_creation_data.hit_point.x,0.5,hit.hit_creation_data.hit_point.z)

func _on_player_found(player:Unit, _aoe:AreaOfEffect, heal_value: float):
	if !is_instance_valid(player): return
	
	if current_rank == 3 || randf() < (0.3 * current_rank):
		var heal_hit = Weapon.Hit.new()
		heal_hit.damage = -heal_value
		heal_hit.damage_type = Damage.Type.Heal
		heal_hit.hit = player
		heal_hit.hit_creation_data = Weapon.HitCreationData.new(Vector3(player.global_position.x,player.find_child("Model").get_height(),player.global_position.z))
		
		player.take_hit(heal_hit)
