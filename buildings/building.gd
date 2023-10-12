extends Node3D

class_name Building

@export var building_type: UnitSpawner.BuildingType
@export var temp_modifier: CardResource

var value: int

var _held_modifier: CardModifier

func _ready():
	#todo popup for choosing card
	_held_modifier = ModifierManager.apply_modifier(temp_modifier)

func _on_tree_exiting():
	ModifierManager.un_apply_modifier(_held_modifier)
	var rarity = _held_modifier.card_resource.rarity
	var sell_scale = 0.8 if rarity == CardResource.CardRarity.UltraRare else (0.5 if rarity == CardResource.CardRarity.Rare else 0.4)
	MoneyManager.I.add_money(sell_scale * value)

func _on_click_area_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			queue_free()
