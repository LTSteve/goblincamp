extends CardModifier

var modified_color: Color

class ColdDethEffect extends Effect:
	var velocity_component: VelocityComponent
	var speed_scale:float
	
	func _init(effected_unit:Unit, effect_duration: float, max_speed_scale:float):
		super._init(effected_unit, effect_duration, false, "ColdDethEffect")
		velocity_component = effected_unit.find_child("VelocityComponent")
		speed_scale = max_speed_scale
	
	func on_apply():
		unit.add_state(Unit.State.CHILLED)
		velocity_component.get_max_speed.add_override([id], _get_max_speed_override)

	func on_remove():
		unit.remove_state(Unit.State.CHILLED)
		velocity_component.get_max_speed.remove_override([id])
	
	func _get_max_speed_override(_base_value:float, current_value:float):
		return max(current_value * speed_scale, 0.01)


func _initialize(data):
	modified_color = Color(data.modified_color)

func _apply(weapon:ChannelingWeapon,_unit):
	#add with high priority so all damage calculations take place first
	weapon.create_hit.add_override([self, "_create_hit_override"], _create_hit_override)
	weapon.create_channeled_scene.add_override([self, "_create_aoe_override"], _create_aoe_override)

func _un_apply(weapon:ChannelingWeapon,_unit):
	weapon.create_hit.remove_override([self, "_create_hit_override"])
	weapon.create_channeled_scene.remove_override([self, "_create_aoe_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage_type = Damage.Type.Cold
	current_value.apply_effects.append(ColdDethEffect.new(current_value.hit, params.chill_duration, (1.0 - params.slow_percent)))
	return current_value

func _create_aoe_override(_base_value: AreaOfEffect, current_value:AreaOfEffect):
	for particle in current_value.particles:
		(particle.process_material as ParticleProcessMaterial).color = modified_color
	return current_value
