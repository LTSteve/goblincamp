extends Node3D

class_name MerchantIconComponent

@onready var icon: Sprite3D = $"Sprite3D"

@export var base_pixel_size = 0.004
@export var hover_pixel_size = 0.0055

func _ready():
	icon.pixel_size = base_pixel_size
	call_deferred("_bind_to_day_night")

func _bind_to_day_night():
	GameManager.I.on_day.connect(_on_day)
	GameManager.I.on_night.connect(_on_night)

func _on_day():
	icon.visible = true

func _on_night(_day):
	icon.visible = false

func _on_mouse_entered():
	icon.pixel_size = hover_pixel_size


func _on_mouse_exited():
	icon.pixel_size = base_pixel_size
