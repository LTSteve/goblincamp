extends Behaviour

class_name BowAndDaggerBehaviour

@export var melee_behaviour:MeleeBehaviour
@export var ranged_behaviour:RangedBehaviour

@export var force_melee: bool
@export var min_nearby_melee_threshold: int
@export var max_nearby_melee_threshold: int
@export var mode_switch_limit: float

class BowAndDaggerBehaviourData:
	var mode_switch_cooldown: float = 0
	var melee: bool = false
	var ranged_weapon: RangedWeapon
	var melee_weapon: MeleeWeapon
	
	func _init(r,m):
		ranged_weapon = r
		melee_weapon = m

func initialize(brain:BrainComponent):
	var bow_and_dagger = brain.weapon_holder.find_child("BowAndDagger") as BowAndDagger
	
	brain.enter_combat.connect(bow_and_dagger._on_enter_combat)
	brain.exit_combat.connect(bow_and_dagger._on_exit_combat)
	brain.request_attack.connect(bow_and_dagger._on_request_attack)
	brain.switch_melee.connect(bow_and_dagger._on_switch_melee)
	
	if brain.flee_range:
		brain.flee_range.body_entered.connect(_on_body_entered_flee_range.bind(brain))
		brain.flee_range.body_exited.connect(_on_body_exited_flee_range.bind(brain))
	
	return BowAndDaggerBehaviourData.new(bow_and_dagger.bow, bow_and_dagger.daggers[0])

func assign_target(delta, brain:BrainComponent, behaviour_data:BowAndDaggerBehaviourData):
	var had_no_target = !brain.target
	behaviour_data.mode_switch_cooldown -= delta
	
	brain.target = Global.nearest_unit(Global.enemies, brain.unit.global_position)
	
	brain.on_lock_target.emit(brain.target)
	
	if brain.target && had_no_target:
		brain.enter_combat.emit()
	
	if !brain.target:
		brain.exit_combat.emit()
	
	_clean_fleeing_list(brain)
	
	if brain.target:
		# throttle mode switches so the unit doesn't get stuck swapping back and forth
		if behaviour_data.mode_switch_cooldown <= 0:
			var new_melee = force_melee || brain.fleeing.size() > min_nearby_melee_threshold && brain.fleeing.size() <= max_nearby_melee_threshold
			if new_melee != behaviour_data.melee:
				behaviour_data.melee = new_melee
				behaviour_data.mode_switch_cooldown = mode_switch_limit
				brain.switch_melee.emit(behaviour_data.melee)

func process(delta, brain:BrainComponent, behaviour_data:BowAndDaggerBehaviourData):
	if brain.target:
		if behaviour_data.melee:
			return melee_behaviour.process(delta, brain, behaviour_data.melee_weapon)
		else:
			return ranged_behaviour.process(delta, brain, behaviour_data.ranged_weapon)
	return false

func _clean_fleeing_list(brain:BrainComponent):
	var to_remove = []
	var index = 0
	for enemy in brain.fleeing:
		if !enemy || !is_instance_valid(enemy):
			to_remove.append(index)
		index += 1
	
	for i in to_remove.size():
		brain.fleeing.remove_at(to_remove[i])

func _on_body_entered_flee_range(enemy, brain:BrainComponent):
	if !(enemy is Unit): return
	brain.fleeing.append(enemy)

func _on_body_exited_flee_range(enemy, brain:BrainComponent):
	if !(enemy is Unit): return
	if !brain.fleeing.has(enemy): return
	brain.fleeing.remove_at(brain.fleeing.find(enemy))