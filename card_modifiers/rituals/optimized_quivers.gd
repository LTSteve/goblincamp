extends CardModifier

func _apply(animation_tree:AnimationTreeExpressionExtension,_unit):
	var time_scale = 1.0 / (1.0 - current_rank * params.speed_increase_per_rank)
	animation_tree.set_attack_timescale(time_scale)

func _un_apply(animation_tree:AnimationTreeExpressionExtension,_unit):
	animation_tree.set_attack_timescale(1)
