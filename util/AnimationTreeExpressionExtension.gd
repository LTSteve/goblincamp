extends AnimationTree

class_name AnimationTreeExpressionExtension

@export var can_rewind: bool:
	get:
		return can_rewind
	set(value):
		can_rewind = value
		if !can_rewind && _rewinding:
			_rewinding = false
			set("parameters/Attack/attack/TimeScale 3/scale", 1)
			set("parameters/Attack/attack_2/TimeScale 3/scale", 1)
			

var _triggers:Dictionary = {}

var _rewinding = false

func _process(_delta):
	var time_scale = ThrottledProcessManager.time_scale
	set("parameters/Attack/attack/TimeScale 2/scale", 1.0 / time_scale)
	set("parameters/Attack/attack_2/TimeScale 2/scale", 1.0 / time_scale)

func create_trigger(trigger_name: String):
	_triggers[trigger_name] = false

func activate_trigger(trigger_name: String, delay: float = 0):
	if !_triggers.has(trigger_name): create_trigger(trigger_name)
	Global.execute_later(func(): _triggers[trigger_name] = true, self, delay)

func use_trigger(trigger_name:String) -> bool:
	var value = _triggers.has(trigger_name) && _triggers[trigger_name]
	if value: _triggers[trigger_name] = false
	return value

