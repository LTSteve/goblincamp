extends Behaviour

class_name ChannelingBehaviour

@export var flee_distance:float = 8
@export var flee_speed_scale: float = 0.8
@export var at_location_dist2: float = 0.75
@export var force_re_target_time: float = 2

class ChannelingCtx:
	var weapon:ChannelingWeapon
	var re_target_delay: float = 0
	func _init(w:ChannelingWeapon):
		weapon = w

func initialize(brain:BrainComponent):
	brain.weapons += _bind_to_all_weapons(brain,typeof(ChannelingWeapon))
	return ChannelingCtx.new(brain.weapons[0] if brain.weapons.size() else null)

func assign_target(delta, brain:BrainComponent, ctx:ChannelingCtx):
	if !ctx.weapon: return
	ctx.re_target_delay -= delta
	
	if !is_instance_valid(brain.target):
		brain.target = null
	
	var had_no_target = !brain.target
	
	var re_target = had_no_target || (ctx.re_target_delay <= 0) || ctx.weapon.has_reached_location(at_location_dist2)
	
	if ! re_target:
		return
	
	if had_no_target || brain.fleeing.size() > 0 || (randf() >= 0.1):
		brain.target = Global.nearest_unit(Global.players if brain.unit.is_enemy else Global.enemies, brain.unit.global_position)
	else:
		brain.target = Global.furthest_unit(Global.players if brain.unit.is_enemy else Global.enemies, brain.target.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target:
		if had_no_target:
			brain.enter_combat.emit()
			brain.begin_channeling.emit()
		brain.request_attack.emit(brain.target, brain.unit)
		ctx.re_target_delay = force_re_target_time
	
	if !brain.target:
		brain.exit_combat.emit()
		brain.end_channeling.emit()

func process(_delta, brain:BrainComponent, ctx:ChannelingCtx):
	if !ctx.weapon: return
	
	var desired_locations = []
	
	var fleeing = false
	for enemy in brain.fleeing:
		fleeing = true
		desired_locations.append(enemy.global_position + Math.unit_v3(brain.unit.global_position - enemy.global_position) * flee_distance)
	
	ctx.weapon.double_speed = fleeing
	
	if fleeing:
		var location_sum = Vector3.ZERO
		for location in desired_locations:
			location_sum += location
	
		brain.unit.set_movement_target(location_sum / max(desired_locations.size(),1), flee_speed_scale if fleeing else 1.0)
		return true
	
	return false
