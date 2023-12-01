extends Node3D

class_name Building

@export var building_type: UnitSpawner.BuildingType

@export var project_sprite: Sprite3D

@export_group("Observables")
@export var buildings_resource: ObservableResource
@export var is_day_resource: ObservableResource

var card_resource: CardResource
var all_cards: Array[CardResource]
var _held_modifier: CardModifier

func _ready():
	buildings_resource.value += [self]

func _on_click_area_input_event(_camera, event, _position, _normal, _shape_idx):
	#if it's not day, don't do anything
	if !is_day_resource.value: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var building_project_panel = DB.I.scenes.building_project_panel_scene.instantiate() as BuildingProjectPanel
			building_project_panel.set_data(card_resource, self)
			HUD.I.on_popup_open(building_project_panel)

func select_card(card:CardResource):
	if _held_modifier:
		ModifierManager.un_apply_modifier(_held_modifier)
	_held_modifier = ModifierManager.apply_modifier(card)
	card_resource = card
	project_sprite.texture = card_resource.icon_texture

#used when a new project is selected in the building project popup. Have to pass extra params cuz i'm wild
func new_project_selected(_building_type:UnitSpawner.BuildingType, chosen_card:CardResource, _all_cards:Array[CardResource]):
	select_card(chosen_card)
