extends Panel

class_name PickProjectModel

@export var card_scene: PackedScene
@export var card_container: Container

var _building_type:UnitSpawner.BuildingType
var _value: int

signal on_card_selected(building_type:UnitSpawner.BuildingType, value: int, resource:CardResource)

func open(building_type:UnitSpawner.BuildingType, value: int):
	if visible: return
	
	_building_type = building_type
	_value = value
	var cards = ModifierManager.generate_card_choices(building_type)
	for card in cards:
		var new_card = card_scene.instantiate() as CardDisplay
		new_card.card_resource = card
		new_card.show_next_rank = true
		new_card.card_selected.connect(_on_card_selected)
		card_container.add_child(new_card)
	
	visible = true

func close():
	for child in card_container.get_children():
		child.queue_free()
	
	visible = false

func _on_card_selected(resource:CardResource):
	on_card_selected.emit(_building_type, _value, resource)
	close()

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		#refund
		MoneyManager.I.add_money(_value)
		close()
