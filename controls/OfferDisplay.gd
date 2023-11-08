extends Panel

class_name OfferDisplay

@onready var texture_rect_1: TextureRect = $"VBoxContainer/HBoxContainer/TextureRect"
@onready var texture_rect_2: TextureRect = $"VBoxContainer/HBoxContainer2/TextureRect"

@onready var number_label_1: Label = $"VBoxContainer/HBoxContainer/Label2"
@onready var number_label_2: Label = $"VBoxContainer/HBoxContainer2/Label2"

@onready var price_button: Button = $"VBoxContainer/MarginContainer/Button"

@onready var name_label: Label = $"VBoxContainer/Label"

var offer:Offer

func _ready():
	texture_rect_1.texture = offer.viewport_texture_1
	texture_rect_2.texture = offer.viewport_texture_2
	
	number_label_1.text = str(offer.type_1_count)
	number_label_2.text = str(offer.type_2_count)
	
	price_button.text = "%d g" % offer.price
	
	name_label.text = offer.name

func disable():
	price_button.text = "PURCHASED"
	price_button.disabled = true
