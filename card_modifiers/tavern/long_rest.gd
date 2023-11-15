extends CardModifier

var hungry_players: Array[Unit] = []

func _initialize(_data):
	DB.I.observables.is_day.value_changed.connect(_on_day) 

#this'll still double-heal sometimes, TODO: if this is an issue rework the process
func _on_day(is_day, _was_day):
	if !is_day: return
	if current_rank <= 0: return
	
	var number_to_heal = current_rank * params.number
	var reloaded = false
	
	while number_to_heal > 0 && DB.I.observables.players.value.size() != 0:
		if hungry_players.size() == 0:
			if reloaded: break
			reloaded = true
			hungry_players.append_array(DB.I.observables.players.value)
			hungry_players.shuffle()
		
		var player = hungry_players.pop_back()
		if !is_instance_valid(player): continue
		
		var health_component = player.find_child("HealthComponent")
		var heal_hit = Weapon.Hit.new()
		heal_hit.damage = -health_component.max_health * params.percent * 0.1
		heal_hit.damage_type = Damage.Type.Heal
		heal_hit.hit = player
		heal_hit.hit_creation_data = Weapon.HitCreationData.new(Vector3(player.global_position.x,player.find_child("Model").get_height(),player.global_position.z))
		
		player.take_hit(heal_hit)
		number_to_heal -= 1
