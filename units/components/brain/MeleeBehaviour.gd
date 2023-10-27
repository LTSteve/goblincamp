extends Behaviour

class_name MeleeBehaviour

@export var comfortable_range_modifier:float = 0.5
@export var nearby_unit_consideration: int = 10
@export var nearby_units_dist2_range:float = 30.0
@export var just_a_few_units: int = 3
@export var targeting_cooldown: float = 0.2
@export var thinking_time: float = 0.75
@export var tactical: bool = true

class MeleeBehaviourContext:
	var weapon:Weapon
	var claim_cardinal
	var lefty:bool
	var thinking: float = 0
	var targeting_cd: float = 0
	var comfortable_dist2: float
	var range2: float
	func _init(w:Weapon, comfortable_range_modifier: float):
		weapon = w
		lefty = randf() > 0.5
		range2 = w.weapon_range * w.weapon_range
		comfortable_dist2 = range2 * comfortable_range_modifier * comfortable_range_modifier

func initialize(brain:BrainComponent):
	brain.weapons = _bind_to_all_weapons(brain, typeof(MeleeWeapon))
	return MeleeBehaviourContext.new(brain.weapons[0] if brain.weapons.size() else null, comfortable_range_modifier)

func assign_target(delta, brain:BrainComponent, ctx):
	if ! ctx.weapon: return
	ctx.targeting_cd -= delta
	if ctx.targeting_cd > 0: return
	ctx.thinking -= delta
	if ctx.thinking > 0: return
	
	var had_no_target = !is_instance_valid(brain.target)
	if had_no_target:
		brain.target = null
	var old_target = brain.target if !had_no_target else null
	
	var all_targets = Global.players if brain.unit.is_enemy else Global.enemies
	var available_targets = Global.nearest_units(all_targets, brain.unit.global_position, nearby_unit_consideration, nearby_units_dist2_range)
	var nearest_unit = Global.nearest_unit(available_targets, brain.unit.global_position)
	
	#if there's a unit in range, just do that
	if nearest_unit && (brain.unit.global_position - nearest_unit.global_position).length_squared() < ctx.range2:
		brain.target = nearest_unit
	elif available_targets.size() <= just_a_few_units:
		if available_targets.size() > 0:
			brain.target = Global.nearest_unit(available_targets, brain.unit.global_position)
		else:
			brain.target = Global.nearest_unit(all_targets, brain.unit.global_position)
	else:
		var lowest_claimed_targets = Global.lowest_claims(available_targets, brain.target)
		brain.target = Global.nearest_unit(lowest_claimed_targets, brain.unit.global_position)
	
	if brain.target != old_target:
		if old_target && ctx.claim_cardinal != null:
			old_target.un_claim_unit(ctx.claim_cardinal)
		if brain.target:
			if tactical:
				ctx.claim_cardinal = brain.target.claim_unit(brain.unit.global_position)
			ctx.targeting_cd = targeting_cooldown
	
	if !is_instance_valid(brain.target):
		#brain.request_attack_rewind.emit()
		brain.exit_combat.emit()
		return
	
	brain.on_lock_target.emit(brain.target)
	
	if had_no_target:
		brain.enter_combat.emit()

func process(_delta, brain:BrainComponent, ctx):
	if ctx.thinking > 0: return true
	
	if !is_instance_valid(brain.target) || !ctx.weapon:
		return false
	
	brain.request_attack.emit(brain.target,brain.unit)
	
	if brain.unit.global_position.distance_squared_to(brain.target.global_position) <= ctx.comfortable_dist2:
		brain.unit.set_movement_target(brain.unit.global_position)
		return true
	
	if ctx.claim_cardinal == null:
		if tactical:
			var inv_separation = (brain.unit.global_position - brain.target.global_position)
			brain.unit.set_movement_target(brain.target.global_position + inv_separation.rotated(Vector3.UP, Math.rad_90 if ctx.lefty else -Math.rad_90) / 2.0)
			ctx.thinking = thinking_time
		else:
			brain.unit.set_movement_target(brain.target.global_position)
	else:
		var claimed_dir:Vector2 = Math.Cardinal_As_Direction[ctx.claim_cardinal]
		var claimed_spot = brain.target.global_position + Math.v2_to_v3(claimed_dir) * ctx.weapon.weapon_range * comfortable_range_modifier
		brain.unit.set_movement_target(claimed_spot)
	
	return true

func clean_up(brain:BrainComponent, ctx):
	if ctx.claim_cardinal && is_instance_valid(brain.target):
		brain.target.un_claim_unit(ctx.claim_cardinal)
