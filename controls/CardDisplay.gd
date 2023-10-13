extends MarginContainer

class_name CardDisplay

@export var card_defaults: CardDefaults
@export var card_resource: CardResource

@export var card_background: TextureRect
@export var card_title: Label
@export var card_icon: TextureRect
@export var card_description: Label

var clickable: bool = true

signal card_selected(resource:CardResource)

func _ready():
	if ! card_resource: return
	if ! clickable:
		card_background.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	card_background.modulate = card_defaults.rarity_colors[card_resource.rarity]
	card_title.text = card_resource.title
	card_icon.texture = card_resource.icon_texture
	#todo: check what rank the card already is
	card_description.text = card_resource.descriptions[0]

func _on_gui_input(event):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		card_selected.emit(card_resource)

func _on_mouse_entered():
	if !clickable: return
	card_background.self_modulate = card_defaults.card_selected_color


func _on_mouse_exited():
	if !clickable: return
	card_background.self_modulate = Color.WHITE
