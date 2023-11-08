extends CardModifier

var hungry_players: Array[Unit] = []

func _initialize(_data):
	GameManager.I.on_day.connect(_on_day)

#this'll still double-heal sometimes, TODO: if this is an issue rework the process
func _on_day():
	if current_rank <= 0: return
	var number_to_heal = current_rank * params.number
	var reloaded = false
	for _i in number_to_heal:
		if hungry_players.size() == 0:
			if reloaded: break
			reloaded = true
			hungry_players.append_array(Global.players)
			hungry_players.shuffle()
			if hungry_players.size() == 0: break
		
		var player = hungry_players.pop_back()
		if !is_instance_valid(player): continue
		
		var health_component = player.find_child("HealthComponent")
		var heal_hit = Weapon.Hit.new()
		heal_hit.damage = -health_component.max_health * params.percent * 0.1
		heal_hit.damage_type = Damage.Type.Heal
		heal_hit.hit = player
		heal_hit.hit_creation_data = Weapon.HitCreationData.new(Vector3(player.global_position.x,player.find_child("Model").get_height(),player.global_position.z))
		
		player.take_hit(heal_hit)
