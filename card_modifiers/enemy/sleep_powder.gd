extends CardModifier

class SleepPowderEffect extends Effect:
	var _brain: BrainComponent
	var _stun: StunBehaviour
	
	func _init(effected_unit:Unit, effect_duration: float):
		super._init(effected_unit, effect_duration, false, "SleepPowder")
		_brain = effected_unit.find_child("BrainComponent")
	
	func on_apply():
		_stun = StunBehaviour.new()
		_brain.add_override_behaviour(_stun)
		unit.on_recieved_hit.connect(_on_recieved_hit)
		unit.add_state(Unit.State.SLEEPING)
	
	func on_remove():
		_brain.remove_override_behaviour(_stun)
		if unit.on_recieved_hit.is_connected(_on_recieved_hit):
			unit.on_recieved_hit.disconnect(_on_recieved_hit)
		unit.remove_state(Unit.State.SLEEPING)
	
	func _on_recieved_hit(_weapon_hit):
		unit.remove_effect(self)


func _initialize(_data):
	#since we don't apply to units, we need to apply ourselves if we were added in the editor
	if current_rank != 0:
		_apply(null,null)

func _apply(_null,_unit):
	if GameManager.I.on_night.is_connected(_on_night): return
	GameManager.I.on_night.connect(_on_night)

func _un_apply(_null,_unit):
	GameManager.I.on_night.disconnect(_on_night)

func _on_night(_day):
	var players = Global.players
	var num_to_sleep = max(floor((params.sleep_rate_per_rank * current_rank) * players.size()), 1)
	var random_indexes = range(players.size())
	
	random_indexes.shuffle()
	for i in random_indexes:
		var player = players[i]
		if !is_instance_valid(player): continue
		
		var sleep_powder_effect = SleepPowderEffect.new(player, randf_range(params.sleep_min, params.sleep_max))
		player.add_effect(sleep_powder_effect)
		
		num_to_sleep -= 1
		if num_to_sleep == 0: break
