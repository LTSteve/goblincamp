extends CardModifier

func _apply(animation_tree:AnimationTree,_unit):
	animation_tree.set("parameters/Attack/conditions/use_attack_2", true)

func _un_apply(animation_tree:AnimationTree,_unit):
	if current_rank == 1:
		animation_tree.set("parameters/Attack/conditions/use_attack_2", false)
