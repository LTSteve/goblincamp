extends Behaviour

class_name DethballBehaviour

@export var flee_distance:float = 8
@export var flee_speed_scale: float = 0.8
@export var at_location_dist2: float = 0.75
@export var force_re_target_time: float = 2

@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

class DethballCtx:
	var weapon:ChannelingWeapon
	var re_target_delay: float = 0
	var active_aoe: AreaOfEffect
	var active_velocity_component: VelocityComponent
	var double_speed: bool = false
	var current_target: Vector3
	var current_target_enemy: bool
	func _init(w:ChannelingWeapon):
		weapon = w

func initialize(brain:BrainComponent):
	brain.weapons += _bind_to_all_weapons(brain,typeof(ChannelingWeapon))
	var channeling_weapon = brain.weapons[0] as ChannelingWeapon
	var ctx = DethballCtx.new(channeling_weapon)
	channeling_weapon.create_channeled_scene.add_override(["_create_aoe_override"], _create_aoe_override.bind(ctx), -1)
	return ctx

func _create_aoe_override(_base_value: AreaOfEffect, current_value: AreaOfEffect, ctx: DethballCtx):
	current_value.callback = _on_hit_landed.bind(ctx.weapon)
	current_value.global_position = Math.v2_to_v3(Math.v3_to_v2(ctx.weapon.channeled_effect_spawn_point.global_position), 0.75)
	ctx.active_velocity_component = current_value.find_child("VelocityComponent") as VelocityComponent
	ctx.active_velocity_component.get_max_speed.add_override(["double_speed"], func(_base_value:float, current_value:float): 
		return (current_value * 2.0) if ctx.double_speed else current_value
	, 0, true)
	ctx.active_aoe = current_value
	return current_value

func assign_target(delta, brain:BrainComponent, ctx:DethballCtx):
	if !ctx.weapon: return
	ctx.re_target_delay -= delta
	
	if !is_instance_valid(brain.target):
		brain.target = null
	
	var had_no_target = !brain.target
	
	var re_target = (Math.v3_to_v2(ctx.current_target - ctx.active_aoe.global_position).length_squared() <= at_location_dist2) if ctx.active_aoe else had_no_target
	
	if ! re_target:
		return
	
	if had_no_target || brain.fleeing.size() > 0 || (randf() >= 0.1):
		brain.target = Global.nearest_unit(players_resource.value if brain.unit.is_enemy else enemies_resource.value, brain.unit.global_position)
	else:
		brain.target = Global.furthest_unit(players_resource.value if brain.unit.is_enemy else enemies_resource.value, brain.target.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target:
		if had_no_target:
			brain.enter_combat.emit()
			brain.begin_channeling.emit()
		brain.request_attack.emit(brain.target, brain.unit)
		ctx.re_target_delay = force_re_target_time
		ctx.current_target = brain.target.global_position
		ctx.current_target_enemy = brain.target.is_enemy
	
	if !brain.target:
		brain.exit_combat.emit()
		brain.end_channeling.emit()

func physics_process(delta, _brain:BrainComponent, ctx:DethballCtx):
	if !is_instance_valid(ctx.active_aoe): return true
	
	if ctx.current_target == ctx.active_aoe.global_position: return true
	
	var movement_separation = Math.v3_to_v2(ctx.current_target - ctx.active_aoe.global_position)
	if movement_separation.length_squared() <= (ctx.active_velocity_component.get_max_speed.execute() * delta):
		ctx.active_aoe.global_position = Math.v2_to_v3(Math.v3_to_v2(ctx.current_target), 0)
		return true
	
	var movement_direction = movement_separation.normalized()

	ctx.active_velocity_component.set_direction(movement_direction)
	
	ctx.active_velocity_component.move_basic(ctx.active_aoe, delta)
	
	return true

func process(_delta, brain:BrainComponent, ctx:DethballCtx):
	if !ctx.weapon: return
	
	var desired_locations = []
	
	var fleeing = false
	for enemy in brain.fleeing:
		fleeing = true
		desired_locations.append(enemy.global_position + Math.unit_v3(brain.unit.global_position - enemy.global_position) * flee_distance)
	
	ctx.double_speed = fleeing
	
	if fleeing:
		var location_sum = Vector3.ZERO
		for location in desired_locations:
			location_sum += location
	
		brain.unit.set_movement_target(location_sum / max(desired_locations.size(),1), flee_speed_scale if fleeing else 1.0)
		return true
	
	return false

func _on_hit_landed(enemy:Unit, aoe:AreaOfEffect, weapon:ChannelingWeapon):
	if !is_instance_valid(enemy): return
	
	var hit_data = weapon.create_hit.execute([enemy, Weapon.HitCreationData.new(aoe.global_position)])
	enemy.take_hit(hit_data)
	weapon.on_hit_landed.emit(hit_data)
