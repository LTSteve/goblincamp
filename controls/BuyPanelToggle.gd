extends Control

class_name BuyPanelToggle

@export var buy_units_button: Button
@export var buy_units_panel: Panel
@export var buy_buildings_button: Button
@export var buy_buildings_panel: Panel


func _on_buy_units_pressed():
	buy_units_button.disabled = true
	buy_buildings_button.disabled = false
	buy_units_panel.visible = true
	buy_buildings_panel.visible = false


func _on_buy_buildings_pressed():
	buy_units_button.disabled = false
	buy_buildings_button.disabled = true
	buy_units_panel.visible = false
	buy_buildings_panel.visible = true
