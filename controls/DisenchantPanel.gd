extends Panel

class_name DisenchantPanel

@onready var card_container: Container = $"Panel/MarginContainer2/Panel/ScrollContainer/MarginContainer/HBoxContainer"
@onready var disenchant_button: Button = $"Panel/MarginContainer3/Button"
@onready var disenchant_button_content: Container = $"Panel/MarginContainer3/Button/HBoxContainer"

@onready var disenchant_cost_label_power: Label = $"Panel/MarginContainer3/Button/HBoxContainer/Label4"
@onready var disenchant_result_label: Label = $"Panel/MarginContainer3/Button/HBoxContainer/Label3"

@onready var disenchant_power_label: Label = $"Panel/Panel/HBoxContainer/Label"

var _disenchant_power_costs: Array[int] = [1, 2, 3]
var _disenchant_results: Array[int] = [1, 2, 3]

var _current_disenchant_power: int = 0
var _card_display_scene: PackedScene

var _selected_card: CardResource

static var I: DisenchantPanel

func _ready():
	I = self
	GameManager.I.on_day.connect(_on_day)
	_card_display_scene = DB.I.scenes.card_display_scene

func set_disenchant_properties(disenchant_power_costs: Array[int], disenchant_results: Array[int]):
	_disenchant_power_costs = disenchant_power_costs
	_disenchant_results = disenchant_results

func add_disenchant_power(power):
	_current_disenchant_power += power
	disenchant_power_label.text = str(_current_disenchant_power)

func _on_day():
	disenchant_button.text = "Select Enchantment"
	disenchant_button.disabled = true
	disenchant_button_content.visible = false
	
	_selected_card = null

func open():
	_load_current_cards()
	visible = true

func _load_current_cards():
	for child in card_container.get_children():
		child.queue_free()
	
	var cards = ModifierManager.get_active_rituals()
	for card in cards:
		var new_card_display = _card_display_scene.instantiate() as CardDisplay
		new_card_display.card_resource = card
		card_container.add_child(new_card_display)
		new_card_display.card_selected.connect(_on_card_selected)

func close():
	visible = false

func _on_card_selected(card:CardResource):
	_select_card(card)
	
	disenchant_button.text = ""
	disenchant_button.disabled = false
	disenchant_button_content.visible = true
	
	disenchant_cost_label_power.text = str(_disenchant_power_costs[card.rarity])
	disenchant_result_label.text = str(_disenchant_results[card.rarity])

func _select_card(card: CardResource):
	_selected_card = card
	for card_display in card_container.get_children():
		card_display.set_selected(card_display.card_resource == card)

func _on_click_disenchant():
	if ! _selected_card: return
	
	var cost = _disenchant_power_costs[_selected_card.rarity]
	
	if _current_disenchant_power >= cost:
		_current_disenchant_power -= cost
		
		ModifierManager.un_apply_card(_selected_card)
		MoneyManager.I.add_money(_disenchant_results[_selected_card.rarity], MoneyManager.MoneyType.Dust)
		
		disenchant_power_label.text = str(_current_disenchant_power)
		_select_card(null)
		_load_current_cards()

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()
