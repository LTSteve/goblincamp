extends CardModifier

func _apply(animation_tree:AnimationTree,_unit):
	var time_scale = 1.0 / (1.0 - current_rank * params.speed_increase_per_rank)
	animation_tree.set("parameters/Attack/attack/TimeScale/scale", time_scale)
	animation_tree.set("parameters/Attack/attack 2/TimeScale/scale", time_scale)

func _un_apply(animation_tree:AnimationTree,_unit):
	animation_tree.set("parameters/Attack/attack/TimeScale/scale", 1)
	animation_tree.set("parameters/Attack/attack 2/TimeScale/scale", 1)
