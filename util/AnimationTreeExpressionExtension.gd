extends AnimationTree

class_name AnimationTreeExpressionExtension

var _triggers:Dictionary = {}

const IN_COMBAT: StringName = "parameters/conditions/in_combat"
const NOT_IN_COMBAT: StringName = "parameters/conditions/not_in_combat"
const USE_ATTACK_2: StringName = "parameters/ScaledAttack/StateMachine/conditions/use_attack_2"
const ATTACK_TIMESCALE: StringName = "parameters/ScaledAttack/TimeScale/scale"
const ATTACK_TIMESCALE_THROTTLED: StringName = "parameters/ScaledAttack/TimeScaleThrottled/scale"
const ATTACK_REWIND: StringName = "parameters/ScaledAttack/StateMachine/conditions/unattack"

func _process(_delta):
	set_attack_timescale_throttled(1.0 / ThrottledProcessManager.time_scale)

func create_trigger(trigger_name: StringName):
	_triggers[trigger_name] = false

func activate_trigger(trigger_name: StringName, delay: float = 0):
	if !_triggers.has(trigger_name): create_trigger(trigger_name)
	Global.execute_later(func(): _triggers[trigger_name] = true, self, delay)

func clear_trigger(trigger_name:StringName):
	if _triggers.has(trigger_name): _triggers[trigger_name] = false;

func use_trigger(trigger_name:StringName) -> bool:
	var value = _triggers.has(trigger_name) && _triggers[trigger_name]
	if value: _triggers[trigger_name] = false
	return value

func set_in_combat(in_combat: bool):
	set(IN_COMBAT, in_combat)
	set(NOT_IN_COMBAT, !in_combat)

func set_use_attack_2(use_attack_2: bool):
	set(USE_ATTACK_2, use_attack_2)

func set_attack_timescale(time_scale:float):
	set(ATTACK_TIMESCALE, time_scale)

func set_attack_timescale_throttled(time_scale:float):
	set(ATTACK_TIMESCALE_THROTTLED, time_scale)

func set_attack_rewind(rewind: bool):
	set(ATTACK_REWIND, rewind)
