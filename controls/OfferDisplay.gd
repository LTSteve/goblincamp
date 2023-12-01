extends Panel

class_name OfferDisplay

@onready var texture_rect_1: TextureRect3D = $"VBoxContainer/HBoxContainer/3DTextureRect"
@onready var texture_rect_2: TextureRect3D = $"VBoxContainer/HBoxContainer2/3DTextureRect"

@onready var number_label_1: Label = $"VBoxContainer/HBoxContainer/Label2"
@onready var number_label_2: Label = $"VBoxContainer/HBoxContainer2/Label2"

@onready var price_button: Button = $"VBoxContainer/MarginContainer/Button"

@onready var name_label: Label = $"VBoxContainer/Label"

var offer:Offer

func _ready():
	call_deferred("_initialize_texture_rects")
	
	number_label_1.text = str(offer.type_1_count)
	number_label_2.text = str(offer.type_2_count)
	
	price_button.text = "%d g" % offer.price
	
	name_label.text = offer.name

func _initialize_texture_rects():
	texture_rect_1.model_scene = offer.model_scene_1
	texture_rect_2.model_scene = offer.model_scene_2
	
	texture_rect_1.initialize()
	texture_rect_2.initialize()

func disable():
	price_button.text = "PURCHASED"
	price_button.disabled = true
