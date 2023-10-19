extends Behaviour

class_name WanderBehaviour

func assign_target(_delta, _brain:BrainComponent, _null):
	return

func process(_delta, brain:BrainComponent, _null):
	brain.unit.set_movement_target(brain.unit.global_position)
	return true

