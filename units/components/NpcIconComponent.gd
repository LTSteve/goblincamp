extends Node3D

class_name NpcIconComponent

@onready var icon: Sprite3D = $"Sprite3D"

@export var base_pixel_size = 0.004
@export var hover_pixel_size = 0.0055

func _ready():
	icon.pixel_size = base_pixel_size
	DB.I.observables.is_day.value_changed.connect(_on_day_changed)

func _on_day_changed(is_day, _was_day):
	icon.visible = is_day

func _on_mouse_entered():
	icon.pixel_size = hover_pixel_size
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	icon.pixel_size = base_pixel_size
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
