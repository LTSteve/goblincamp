extends MarginContainer

class_name CardDisplay

@export var card_defaults: CardDefaults
@export var card_resource: CardResource

@export var card_background: TextureRect
@export var card_title: Label
@export var card_icon: TextureRect
@export var card_description: Label

var clickable: bool = true
var show_next_rank: bool = false

signal card_selected(resource:CardResource)

func _ready():
	if ! card_resource: return
	if ! clickable:
		card_background.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	card_background.modulate = card_defaults.rarity_colors[card_resource.rarity]
	card_title.text = card_resource.title
	card_icon.texture = card_resource.icon_texture
	var current_modifier = ModifierManager.get_modifier_by_resource(card_resource)
	var current_rank = current_modifier.current_rank
	var text = card_resource.descriptions[min(card_resource.descriptions.size() - 1, current_rank)]
	if current_rank >= (card_resource.descriptions.size() - 1):
		card_description.text = ExpressionsParser.parse(text, { "current_rank": current_rank + (1 if show_next_rank else 0)}, current_modifier.params)
	else:
		card_description.text = text

func _on_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		card_selected.emit(card_resource)

func _on_mouse_entered():
	if !clickable: return
	card_background.self_modulate = card_defaults.card_selected_color


func _on_mouse_exited():
	if !clickable: return
	card_background.self_modulate = Color.WHITE
