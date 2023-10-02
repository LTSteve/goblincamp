extends AnimationTree

class_name AnimationTreeExpressionExtension

var _triggers:Dictionary = {}

func create_trigger(trigger_name: String):
	_triggers[trigger_name] = false

func activate_trigger(trigger_name: String):
	if !_triggers.has(trigger_name): create_trigger(trigger_name)
	_triggers[trigger_name] = true

func use_trigger(trigger_name:String) -> bool:
	var value = _triggers.has(trigger_name) && _triggers[trigger_name]
	if value: _triggers[trigger_name] = false
	return value
