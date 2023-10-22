extends Behaviour

class_name MeleeBehaviour

@export var comfortable_range_modifier:float = 0.5
@export var nearby_unit_consideration: int = 10
@export var nearby_units_dist2_range:float = 30.0
@export var just_a_few_units: int = 3

class MeleeBehaviourContext:
	var weapon:Weapon
	var claim_cardinal
	var lefty:bool
	var thinking: float = 0
	func _init(w):
		weapon = w
		lefty = randf() > 0.5

func initialize(brain:BrainComponent):
	brain.weapons = _bind_to_all_weapons(brain)
	return MeleeBehaviourContext.new(brain.weapons[0] if brain.weapons.size() else null)

func assign_target(delta, brain:BrainComponent, ctx):
	if ! ctx.weapon: return
	ctx.thinking -= delta
	if ctx.thinking > 0: return
	
	var had_no_target = !is_instance_valid(brain.target)
	var old_target = brain.target if !had_no_target else null
	
	var all_targets = Global.players if brain.unit.is_enemy else Global.enemies
	var available_targets = Global.nearest_units(all_targets, brain.unit.global_position, nearby_unit_consideration, nearby_units_dist2_range)
	var nearest_unit = Global.nearest_unit(available_targets, brain.unit.global_position)
	
	#if there's a unit in melee range, just do that
	if nearest_unit && (brain.unit.global_position - nearest_unit.global_position).length_squared() < (ctx.weapon.weapon_range * ctx.weapon.weapon_range):
		brain.target = nearest_unit
	elif available_targets.size() <= just_a_few_units:
		if available_targets.size() > 0:
			brain.target = Global.nearest_unit(available_targets, brain.unit.global_position)
		else:
			brain.target = Global.nearest_unit(all_targets, brain.unit.global_position)
	else:
		var lowest_claimed_targets = Global.lowest_claims(available_targets)
		brain.target = Global.nearest_unit(lowest_claimed_targets, brain.unit.global_position)
	
	if brain.target != old_target:
		if old_target && ctx.claim_cardinal != null:
			old_target.un_claim_unit(ctx.claim_cardinal)
		if brain.target:
			ctx.claim_cardinal = brain.target.claim_unit(brain.unit.global_position)
	
	if !is_instance_valid(brain.target):
		brain.exit_combat.emit()
		return
	
	brain.on_lock_target.emit(brain.target)
	
	if had_no_target:
		brain.enter_combat.emit()

func process(_delta, brain:BrainComponent, ctx):
	if ctx.thinking > 0: return true
	
	if brain.target && ctx.weapon:
		if brain.unit.global_position.distance_to(brain.target.global_position) > ctx.weapon.weapon_range * comfortable_range_modifier:
			if ctx.claim_cardinal == null:
				#todo: head afeild
				var inv_separation = (brain.unit.global_position - brain.target.global_position)
				brain.unit.set_movement_target(inv_separation.rotated(Vector3.UP, Math.rad_90 if ctx.lefty else -Math.rad_90))
				ctx.thinking = 2.0
			else:
				var claimed_dir:Vector2 = Math.Cardinal_As_Direction[ctx.claim_cardinal]
				var claimed_spot = brain.target.global_position + Math.v2_to_v3(claimed_dir) * ctx.weapon.weapon_range * comfortable_range_modifier
				brain.unit.set_movement_target(claimed_spot)
		else:
			brain.unit.set_movement_target(brain.unit.global_position)
		brain.request_attack.emit(brain.target,brain.unit)
		return true
	
	return false

func clean_up(brain:BrainComponent, ctx):
	if ctx.claim_cardinal:
		brain.target.un_claim_unit(ctx.claim_cardinal)
