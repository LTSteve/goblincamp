extends Area3D

signal clicked()

@export var node_to_scale: Node3D

@export var node_unscaled: Vector3 = Vector3.ONE
@export var node_scaled: Vector3 = Vector3(1.2,1.2,1.2)
@export var node_scale_time: float = 0.2

var _tween: Tween

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	if !node_to_scale: return
	_tween = _reset_tween()
	_tween.tween_property(node_to_scale, "scale", node_scaled, node_scale_time)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	if !node_to_scale: return
	_tween = _reset_tween()
	_tween.tween_property(node_to_scale, "scale", node_unscaled, node_scale_time)

func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if !(event is InputEventMouseButton) || !event.pressed: return
	clicked.emit()

func _reset_tween() -> Tween:
	if _tween:
		_tween.stop()
		_tween = null
	_tween = self.create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	return _tween
