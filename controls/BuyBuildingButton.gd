extends Button

@export var building_type: UnitSpawner.BuildingType
@export var cost: int = 100

signal request_spawn(building_type: UnitSpawner.BuildingType, value: int)

func _ready():
	text += "\n(%d G)" % cost

func _on_pressed():
	if MoneyManager.I.try_spend(cost):
		request_spawn.emit(building_type, cost)
