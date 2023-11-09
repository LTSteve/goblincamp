extends Behaviour

class_name EarHuntBehaviour

class EarHuntContext:
	var targeted_ear: GoblinEar = null

func initialize(_brain:BrainComponent):
	return EarHuntContext.new()

func assign_target(_delta, brain:BrainComponent, ctx:EarHuntContext):
	if is_instance_valid(ctx.targeted_ear): return ctx
	if Global.ears.size() == 0: return ctx
	ctx.targeted_ear = Global.claim_nearest_unclaimed_ear(brain.unit.global_position)
	return ctx

func process(_delta, brain:BrainComponent, ctx:EarHuntContext):
	if !is_instance_valid(ctx.targeted_ear): return false
	brain.unit.set_movement_target(ctx.targeted_ear.global_position)
	return true

