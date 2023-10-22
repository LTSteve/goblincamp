extends Behaviour

class_name StunBehaviour

class StunData:
	var has_reached_target:bool = false

func initialize(_brain:BrainComponent):
	return StunData.new()

func process(_delta, brain:BrainComponent, stun_data:StunData):
	if stun_data.has_reached_target: return true
	brain.unit.set_movement_target(brain.unit.global_position)
	stun_data.has_reached_target = true
	return true

