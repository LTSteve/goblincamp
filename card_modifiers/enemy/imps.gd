extends CardModifier

func _apply(_null,_unit):
	GameManager.I.add_enemy_unit_type(UnitSpawner.UnitType.Imp)
	UnitSpawner.I.double_imps = current_rank == 2

func _un_apply(_null,_unit):
	GameManager.I.remove_enemy_unit_type(UnitSpawner.UnitType.Imp)
	UnitSpawner.I.double_imps = false
