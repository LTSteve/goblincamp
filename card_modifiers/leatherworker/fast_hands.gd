extends CardModifier

func _apply(animation_tree:AnimationTree,_unit):
	var time_scale = 1 + current_rank * params.speed_increase
	animation_tree.set("parameters/%s/TimeScale/scale" % params.draw_animation_name, time_scale)
	animation_tree.set("parameters/%s/TimeScale/scale" % params.stow_animation_name, time_scale)

func _un_apply(animation_tree:AnimationTree,_unit):
	animation_tree.set("parameters/%s/TimeScale/scale" % params.draw_animation_name, 1)
	animation_tree.set("parameters/%s/TimeScale/scale" % params.stow_animation_name, 1)
