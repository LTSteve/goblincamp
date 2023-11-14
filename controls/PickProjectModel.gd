extends Panel

class_name PickProjectModel

var card_scene: PackedScene
@export var card_container: Container

var _building_type:UnitSpawner.BuildingType
var _ritual: Ritual
var _cards: Array[CardResource]

static var I: PickProjectModel

signal on_building_card_selected(building_type:UnitSpawner.BuildingType, chosen_card:CardResource, all_cards:Array[CardResource])

func _ready():
	card_scene = DB.I.scenes.card_scene
	I = self

func open(building_type:UnitSpawner.BuildingType):
	if visible: return
	
	_building_type = building_type
	_cards = ModifierManager.generate_card_choices(building_type)
	_display_cards()
	
	visible = true

func open_ritual(ritual: Ritual):
	if visible: return
	
	_ritual = ritual
	_cards = ModifierManager.generate_ritual_card_choices(_ritual.type, _ritual.size)
	_display_cards()
	
	visible = true

func _display_cards():
	for card in _cards:
		var new_card = card_scene.instantiate() as CardDisplay
		new_card.card_resource = card
		new_card.show_next_rank = true
		new_card.card_selected.connect(_on_card_selected)
		card_container.add_child(new_card)

func close():
	for child in card_container.get_children():
		child.queue_free()
	
	visible = false

func _on_card_selected(resource:CardResource):
	if _ritual:
		_ritual = null
		ModifierManager.apply_modifier(resource)
	else:
		on_building_card_selected.emit(_building_type, resource, _cards)
		
	close()
