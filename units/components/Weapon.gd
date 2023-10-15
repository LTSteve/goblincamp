class_name Weapon

class Hit:
	var direction:Vector2
	var crit_damage_multiplier: float
	var damage:float
	var pushback:float
	var hit_stun:float
	var crit: bool
	var damage_type: Damage.Type
	var hit_by
	var hit:Unit
	var hit_point:Vector3
	
	var post_crit_damage: float:
		get:
			return damage * (crit_damage_multiplier if crit else 1.0)
	
	func duplicate():
		var obj = Hit.new()
		obj.direction = direction
		obj.crit_damage_multiplier = crit_damage_multiplier
		obj.damage = damage
		obj.pushback = pushback
		obj.hit_stun = hit_stun
		obj.crit = crit
		obj.damage_type = damage_type
		obj.hit_by = hit_by
		obj.hit = hit
		obj.hit_point = hit_point
		return obj

static func _process(this, delta):
	this.current_cooldown -= delta

static func _on_enter_combat(this):
	this.animation_tree.set("parameters/conditions/in_combat", true)
	this.animation_tree.set("parameters/conditions/not_in_combat", false)

static func _on_exit_combat(this):
	this.animation_tree.set("parameters/conditions/in_combat", false)
	this.animation_tree.set("parameters/conditions/not_in_combat", true)

static func _try_to_attack(this, target:Unit, me:Unit) -> bool:
	#in range?
	if(this.current_cooldown > 0 
	|| (target.global_position - me.global_position).length() > this.weapon_range
	|| (this.animation_tree.get("parameters/playback").get_current_node() != "idle_combat")) : return false
	
	#trigger animation
	this.animation_tree.activate_trigger("attack")
	
	#reset cooldown
	this.current_cooldown = this.cooldown
	
	return true

static func _create_hit(this, unit:Unit, hit_point:Vector3 = Vector3.ZERO) -> Weapon.Hit:
	
	var hit_data = Hit.new()
	hit_data.direction = Math.unit(Math.v3_to_v2(unit.global_position-this.global_position))
	hit_data.crit = randf() < this.crit_chance
	hit_data.crit_damage_multiplier = this.crit_damage_multiplier
	hit_data.damage = round(this.damage)
	hit_data.pushback = this.pushback
	hit_data.hit_stun = this.hit_stun
	hit_data.damage_type = this.damage_type
	hit_data.hit_by = this
	hit_data.hit = unit
	hit_data.hit_point = hit_point
	return hit_data
