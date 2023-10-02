extends Node

@export var worth_base: int = 100
@export var worth_varience: int = 20

func _on_health_component_died():
	var worth = worth_base + randi_range(-worth_varience, worth_varience)
	MoneyManager.I.add_money(worth)
