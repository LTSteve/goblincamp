extends CardModifier

func _initialize(_data):
	#since we don't apply to units, we need to apply ourselves if we were added in the editor
	if current_rank != 0:
		_apply(null,null)

func _apply(_null,_unit):
	if GameManager.I.unlocked_enemy_types.has(UnitSpawner.UnitType.Imp): return
	GameManager.I.unlocked_enemy_types.append(UnitSpawner.UnitType.Imp)
	GameManager.I.force_spawn_enemy_type = UnitSpawner.UnitType.Imp
	UnitSpawner.I.double_imps = current_rank == 2

func _un_apply(_null,_unit):
	GameManager.I.unlocked_enemy_types = GameManager.I.unlocked_enemy_types.filter(func(enemy_type): return enemy_type != UnitSpawner.UnitType.Imp)
	UnitSpawner.I.double_imps = false
