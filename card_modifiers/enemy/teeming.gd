extends CardModifier

func _initialize(_data):
	#since we don't apply to units, we need to apply ourselves if we were added in the editor
	if current_rank != 0:
		_apply(null,null)

func _apply(_null,_unit):
	#can probably stand to reduce overall enemy value by some % as well
	GameManager.I.flat_enemy_power_increase += current_rank * params.enemy_power_per_rank

func _un_apply(_null,_unit):
	GameManager.I.flat_enemy_power_increase -= current_rank * params.enemy_power_per_rank
