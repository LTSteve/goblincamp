extends Node3D

class_name Building

@export var building_type: UnitSpawner.BuildingType

@export var project_model_container: Node3D

@export_group("Observables")
@export var buildings_resource: ObservableResource
@export var is_day_resource: ObservableResource

var _height_component: HeightComponent

var card_resource: CardResource
var all_cards: Array[CardResource]
var _held_modifier: CardModifier

var _arc_progress: float = 0.0

var _resource_arc: Arc
var _resource_value: int
var _resource_type: MoneyManager.MoneyType
var _resource_model: Node3D
var _project_model: Node3D
var _project_turntable: Turntable

func _ready():
	if project_model_container: _project_turntable = project_model_container.find_child("Turntable");
	_height_component = get_children().filter(func(child): return child is HeightComponent)[0]
	buildings_resource.value += [self]

func _on_click_area_input_event(_camera, event, _position, _normal, _shape_idx):
	#if it's not day, don't do anything
	if !is_day_resource.value: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var building_project_panel = DB.I.scenes.building_project_panel_scene.instantiate() as BuildingProjectPanel
			building_project_panel.set_data(card_resource, self)
			HUD.I.on_popup_open(building_project_panel)

func _on_click_area_mouse_enter():
	if !is_day_resource.value: return
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	_project_turntable.set_process(true)

func _on_click_area_mouse_exit():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	_project_turntable.set_process(false)

func select_card(card:CardResource):
	if _held_modifier:
		ModifierManager.un_apply_modifier(_held_modifier, self)
	_held_modifier = ModifierManager.apply_modifier(card, self)
	card_resource = card
	
	#clear current project model
	if _project_model: 
		_project_model.queue_free()
	_project_model = card_resource.icon_model.instantiate()
	project_model_container.add_child(_project_model)

#used when a new project is selected in the building project popup. Have to pass extra params cuz i'm wild
func new_project_selected(_building_type:UnitSpawner.BuildingType, chosen_card:CardResource, _all_cards:Array[CardResource]):
	select_card(chosen_card)

func send_resource(count: int, resource: MoneyManager.MoneyType):
	_resource_value = count
	_resource_type = resource
	_resource_model = card_resource.icon_model.instantiate()
	get_tree().root.add_child(_resource_model)
	_resource_model.global_position = _height_component.global_position + Vector3.UP
	_resource_arc = Arc.new(_resource_model.global_position, TreasureChest.LOCATION, TreasureChest.ARC_HEIGHT)
	var arc_tween = create_tween()
	arc_tween.tween_property(self, "_arc_progress", 1.0, TreasureChest.ARC_TIME)
	Global.execute_later(func(): set_process(true), self, randf() * 0.2)

func _process(_delta):
	if !_resource_arc: 
		set_process(false)
		return
	
	if _arc_progress < 1.0:
		_resource_model.global_position = _resource_arc.get_arc_location(_arc_progress)
		return
	
	MoneyManager.I.add_money(_resource_value, _resource_type)
	_resource_model.queue_free()
	_resource_model = null
	_resource_arc = null
	
