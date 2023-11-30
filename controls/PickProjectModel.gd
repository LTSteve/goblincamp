extends UIPopup

class_name PickProjectModel

@onready var card_holder_texture_rect: TextureRect3D = $"MarginContainer2/3DTextureRect"

var card_scene: PackedScene
var card_container: CardContainer

var _building_type:UnitSpawner.BuildingType
var _ritual: Ritual
var _cards: Array[CardResource]

signal on_building_card_selected(building_type:UnitSpawner.BuildingType, chosen_card:CardResource, all_cards:Array[CardResource])

func _ready():
	card_scene = DB.I.scenes.card_display_scene
	call_deferred("_assign_card_container")

func _assign_card_container():
	card_container = card_holder_texture_rect.model
	for card in _cards:
		var new_card = card_scene.instantiate() as CardDisplay
		new_card.card_resource = card
		new_card.show_next_rank = true
		card_container.add_child(new_card)
	card_container.tween_into_position()

func generate_building_cards(building_type:UnitSpawner.BuildingType):
	_building_type = building_type
	_cards = ModifierManager.generate_card_choices(building_type)

func generate_ritual_cards(ritual: Ritual):
	_ritual = ritual
	_cards = ModifierManager.generate_ritual_card_choices(_ritual.type, _ritual.size)

func open():
	super.open()

func close():
	for child in card_container.get_children():
		child.queue_free()
	
	super.close()

func _on_card_selected(resource:CardResource):
	if _ritual:
		_ritual = null
		ModifierManager.apply_modifier(resource)
	else:
		on_building_card_selected.emit(_building_type, resource, _cards)
	
	close()

func on_choose_card():
	var selected_card = card_container.get_active_card()
	_on_card_selected(selected_card.card_resource)


func _on_card_holder_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		var pressed_event = event as InputEventMouseButton
		var position_percent = pressed_event.position.x / (card_holder_texture_rect.get_rect().size.x as float)
		if position_percent > 0.66:
			card_container.shift_right()
		if position_percent < 0.33:
			card_container.shift_left()
