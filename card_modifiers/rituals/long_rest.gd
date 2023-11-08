extends CardModifier

func _initialize(_data):
	GameManager.I.on_day.connect(_on_day)

func _on_day():
	if current_rank <= 0: return
	for player in Global.players:
		if !is_instance_valid(player): continue
		
		var health_component = player.find_child("HealthComponent")
		var heal_hit = Weapon.Hit.new()
		heal_hit.damage = -health_component.max_health * current_rank * params.percent_per_rank * 0.1
		heal_hit.damage_type = Damage.Type.Heal
		heal_hit.hit = player
		heal_hit.hit_creation_data = Weapon.HitCreationData.new(Vector3(player.global_position.x,player.find_child("Model").get_height(),player.global_position.z))
		
		player.take_hit(heal_hit)
