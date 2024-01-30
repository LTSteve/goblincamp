extends CardModifier

func _apply(animation_tree:AnimationTreeExpressionExtension,_unit):
	if current_rank == 0: return
	animation_tree.set_use_attack_2(true)

func _un_apply(animation_tree:AnimationTreeExpressionExtension,_unit):
	if current_rank == 1:
		animation_tree.set_use_attack_2(false)
