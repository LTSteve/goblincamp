extends Button

@export var unit_type: UnitSpawner.UnitType
@export var cost: int = 100

signal request_spawn(unit_type: UnitSpawner.UnitType)

func _ready():
	text += "\n(%d G)" % cost

func _on_pressed():
	if MoneyManager.I.try_spend(cost):
		request_spawn.emit(unit_type)
