extends Node3D

class_name TreasureChest

@export var treasure_models: Array[Node3D]
@export_category("Signal Buses")
@export var on_treasure_chest_clicked_resource: SignalBus

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()

func _on_click():
	on_treasure_chest_clicked_resource.on_signal.emit()

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
