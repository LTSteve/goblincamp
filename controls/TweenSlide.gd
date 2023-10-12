extends Control

class_name TweenSlide

@export var me: TweenSlide = self
@export var slide_in_value:Vector2
@export var slide_out_value: Vector2
@export var slide_time: float = 0.5
@export var ease_type: Tween.EaseType

var _tween: Tween

func slide_in():
	_tween = _reset_tween()
	_tween.tween_property(me, "position", slide_in_value, slide_time)

func slide_out():
	_tween = _reset_tween()
	_tween.tween_property(me, "position",  slide_out_value, slide_time)

func _reset_tween() -> Tween:
	if _tween:
		_tween.stop()
		_tween = null
	_tween = me.create_tween()
	_tween.set_ease(ease_type)
	return _tween
