class_name Weapon

class HitCreationData:
	var hit_point: Vector3 = Vector3.ZERO
	var can_chain: bool = true
	var base_damage_scale: float = 1.0
	var base_pushback_scale: float = 1.0
	var can_crit: bool = true
	var apply_effects: Array[Effect] = []
	
	func _init(point:Vector3 = Vector3.ZERO):
		hit_point = point

class Hit:
	var direction:Vector2
	var crit_damage_multiplier: float
	var is_crit: bool
	var damage:float
	var pushback:float
	var hit_stun:float
	var flat_armor:int
	var crit_chance: float
	var damage_type: Damage.Type
	var hit_by
	var hit:Unit
	var apply_effects:Array[Effect] = []
	var hit_creation_data:HitCreationData
	
	var post_crit_damage: float:
		get:
			var dmg = (damage * crit_damage_multiplier) if is_crit else damage
			if dmg > 1:
				dmg = clampi(dmg - flat_armor, 1, dmg)
			return dmg
	
	func duplicate():
		var obj = Hit.new()
		obj.direction = direction
		obj.crit_damage_multiplier = crit_damage_multiplier
		obj.is_crit = is_crit
		obj.damage = damage
		obj.pushback = pushback
		obj.hit_stun = hit_stun
		obj.crit_chance = crit_chance
		obj.damage_type = damage_type
		obj.hit_by = hit_by
		obj.hit = hit
		obj.hit_creation_data = hit_creation_data
		obj.flat_armor = flat_armor
		obj.apply_effects = apply_effects
		return obj

static func _on_enter_combat(this):
	Global.execute_later(func(): 
		this.animation_tree.set("parameters/conditions/in_combat", true)
		this.animation_tree.set("parameters/conditions/not_in_combat", false)
		, this, this.animation_delay)

static func _on_exit_combat(this):
	Global.execute_later(func(): 
		this.animation_tree.set("parameters/conditions/in_combat", false)
		this.animation_tree.set("parameters/conditions/not_in_combat", true)
		, this, this.animation_delay)

static func _try_to_attack(this, target:Unit, me:Unit) -> bool:
	#in range and ready to fire?
	if(this.disabled
	|| (target.global_position - me.global_position).length() > this.weapon_range
	|| (this.animation_tree.get("parameters/playback").get_current_node() != "idle_combat")) : return false
	
	#trigger animation
	this.animation_tree.activate_trigger("attack", this.animation_delay)
	
	return true

static func _create_hit(this, unit:Unit, hit_creation_data:HitCreationData = HitCreationData.new()) -> Weapon.Hit:
	
	var hit_data = Hit.new()
	hit_data.direction = Math.unit(Math.v3_to_v2(unit.global_position-this.global_position))
	hit_data.crit_chance = this.crit_chance if hit_creation_data.can_crit else 0
	hit_data.crit_damage_multiplier = this.crit_damage_multiplier
	hit_data.damage = round(this.damage * hit_creation_data.base_damage_scale)
	hit_data.pushback = this.pushback * hit_creation_data.base_pushback_scale
	hit_data.hit_stun = this.hit_stun
	hit_data.damage_type = this.damage_type
	hit_data.hit_by = this
	hit_data.hit = unit
	hit_data.hit_creation_data = hit_creation_data
	hit_data.apply_effects = hit_creation_data.apply_effects
	return hit_data
