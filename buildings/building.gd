extends Node3D

class_name Building

@export var building_type: UnitSpawner.BuildingType

var value: int
var card_resource: CardResource

var sell_value: int:
	get:
		var rarity = _held_modifier.card_resource.rarity
		var sell_scale = 0.8 if rarity == CardResource.CardRarity.UltraRare else (0.5 if rarity == CardResource.CardRarity.Rare else 0.4)
		return sell_scale * value

var _held_modifier: CardModifier

func _ready():
	_held_modifier = ModifierManager.apply_modifier(card_resource)
	Global.buildings.append(self)

func _on_tree_exiting():
	ModifierManager.un_apply_modifier(_held_modifier)
	MoneyManager.I.add_money(sell_value)
	Global.buildings = Global.buildings.filter(func(building): return building != self)

func _on_click_area_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			SellBuildingPanel.I.open(card_resource, self)

func sell():
	queue_free()
