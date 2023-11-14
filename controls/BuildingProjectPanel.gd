extends Panel

class_name BuildingProjectPanel

@export var title:Label
@export var card_container:Container
var card_display_scene: PackedScene

var _selected_card: CardResource
var _cards: Array[CardResource]
var _building: Building

static var I: BuildingProjectPanel

func _ready():
	card_display_scene = DB.I.scenes.card_scene
	I = self

func open(card:CardResource, building:Building):
	if visible: return
	
	_selected_card = card
	_cards = building.all_cards
	_building = building
	
	title.text = building.get_groups()[0].to_upper()
	
	for child in card_container.get_children():
		child.queue_free()
	
	for c in _cards:
		var card_display = card_display_scene.instantiate() as CardDisplay
		card_display.card_resource = c
		card_display.selected = c == _selected_card
		card_display.card_selected.connect(_on_card_selected)
		card_container.add_child(card_display)
	
	visible = true

func _on_card_selected(card_resource:CardResource):
	_building.select_card(card_resource)
	for card_display in card_container.get_children():
		card_display.update_selected(card_display.card_resource == card_resource)

func close():
	visible = false

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()
