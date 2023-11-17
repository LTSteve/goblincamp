extends Behaviour

class_name EarHuntBehaviour

class EarHuntContext:
	#set externally
	var targeted_ears: Array[GoblinEar] = []

func initialize(_brain:BrainComponent):
	return EarHuntContext.new()

func assign_target(_delta, _brain:BrainComponent, ctx:EarHuntContext):
	if ctx.targeted_ears.size() == 0 || is_instance_valid(ctx.targeted_ears[0]): return ctx
	
	ctx.targeted_ears.remove_at(0)
	
	return ctx

func process(_delta, brain:BrainComponent, ctx:EarHuntContext):
	if ctx.targeted_ears.size() == 0 || !is_instance_valid(ctx.targeted_ears[0]): return false
	brain.unit.set_movement_target(ctx.targeted_ears[0].global_position)
	return true

func get_id():
	return "EarHuntBehaviour"
