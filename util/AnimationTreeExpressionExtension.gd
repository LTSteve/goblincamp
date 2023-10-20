extends AnimationTree

class_name AnimationTreeExpressionExtension

var _triggers:Dictionary = {}

var _cached_time_scale = 1

func _process(_delta):
	if _cached_time_scale == GameManager.time_scale: return
	_cached_time_scale = GameManager.time_scale
	set("parameters/Attack/attack/TimeScale 2/scale", 1.0 / _cached_time_scale)
	set("parameters/Attack/attack_2/TimeScale 2/scale", 1.0 / _cached_time_scale)

func create_trigger(trigger_name: String):
	_triggers[trigger_name] = false

func activate_trigger(trigger_name: String, delay: float = 0):
	if !_triggers.has(trigger_name): create_trigger(trigger_name)
	Global.execute_later(func(): _triggers[trigger_name] = true, self, delay)

func use_trigger(trigger_name:String) -> bool:
	var value = _triggers.has(trigger_name) && _triggers[trigger_name]
	if value: _triggers[trigger_name] = false
	return value
