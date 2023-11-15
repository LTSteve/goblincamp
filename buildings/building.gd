extends Node3D

class_name Building

@export var building_type: UnitSpawner.BuildingType

@export var project_sprite: Sprite3D

@export var buildings_resource: ObservableResource

var card_resource: CardResource
var all_cards: Array[CardResource]
var _held_modifier: CardModifier

func _ready():
	buildings_resource.value += [self]

func _on_click_area_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			BuildingProjectPanel.I.open(card_resource, self)

func select_card(card:CardResource):
	if _held_modifier:
		ModifierManager.un_apply_modifier(_held_modifier)
	_held_modifier = ModifierManager.apply_modifier(card)
	card_resource = card
	project_sprite.texture = card_resource.icon_texture
