extends Panel

class_name SellBuildingPanel

@export var title:Label
@export var sell_button:Button
@export var card_container:Container
@export var card_display_scene: PackedScene

var _card: CardResource
var _building: Building

static var I: SellBuildingPanel

func _ready():
	I = self

func open(card:CardResource, building:Building):
	if visible: return
	
	_card = card
	_building = building
	
	title.text = building.get_groups()[0].to_upper()
	sell_button.text = "Sell (%s)" % building.sell_value
	var card_display = card_display_scene.instantiate() as CardDisplay
	card_display.card_resource = card
	card_display.clickable = false
	card_container.add_child(card_display)
	
	visible = true

func close():
	visible = false

func click_sell():
	_building.sell()
	close()

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()
