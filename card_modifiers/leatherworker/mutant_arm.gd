extends CardModifier

func _apply(bow_and_dagger,_unit):
	if current_rank == 0: return
	bow_and_dagger.mutant = true

func _un_apply(bow_and_dagger,_unit):
	bow_and_dagger.mutant = false
