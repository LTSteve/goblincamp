extends CardModifier

class BleedEffect extends Effect:
	var tick_damage: int
	var tick_time: float = 1.5
	var original_hit: Weapon.Hit
	
	var _current_tick_cooldown: float
	
	func _init(weapon_hit: Weapon.Hit, damage_scale:float, id_append: String):
		id = "SerrationBleedEffect%s" % id_append
		buff = false
		duration = 10
		unit = weapon_hit.hit
		original_hit = weapon_hit
		tick_damage = ceil(weapon_hit.damage * damage_scale * tick_time / duration)
		_current_tick_cooldown = tick_time
	
	func update(delta:float):
		if update_duration_and_return_is_finished(delta): return
		
		_current_tick_cooldown -= delta
		if _current_tick_cooldown > 0: return
		_current_tick_cooldown += tick_time
		
		var hit_data = Weapon.Hit.new()
		hit_data.damage = tick_damage
		hit_data.hit_stun = 0
		hit_data.damage_type = Damage.Type.Bleed
		hit_data.hit_by = original_hit.hit_by if is_instance_valid(original_hit.hit_by) else null 
		hit_data.hit = unit
		unit.take_hit(hit_data)

func _apply(weapon:MeleeWeapon,_unit:Unit):
	#only need to connect if this is the first rank
	if current_rank == 1:
		weapon.on_hit_landed.connect(_on_hit_landed)

func _un_apply(weapon:MeleeWeapon,_unit:Unit):
	#only need to disconnect if this is the last rank
	if current_rank == 1:
		weapon.on_hit_landed.disconnect(_on_hit_landed)

func _on_hit_landed(weapon_hit:Weapon.Hit):
	#apply effect to weapon_hit.unit
	var effect = BleedEffect.new(weapon_hit, current_rank * 0.2, str(weapon_hit.hit_by.get_instance_id()))
	weapon_hit.hit.add_effect(effect)
