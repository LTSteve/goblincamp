class_name Tweenifier

var _me: Node
var _property: String
var _slide_time: float
var _trans_type: Tween.TransitionType
var _ease_type: Tween.EaseType

var _tween: Tween

signal done()

func _init(me:Node, property: String, slide_time: float
, ease_type: Tween.EaseType = Tween.EaseType.EASE_IN_OUT
, trans_type:Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR):
	_me = me
	_property = property
	_slide_time = slide_time
	_ease_type = ease_type
	_trans_type = trans_type

func tween(value) -> Tweenifier:
	_tween = _reset_tween()
	_tween.tween_property(_me, _property, value, _slide_time)
	return self

func _reset_tween() -> Tween:
	if _tween:
		_tween.stop()
		_tween.finished.disconnect(_on_done)
		_tween = null
	_tween = _me.create_tween()
	_tween.set_ease(_ease_type)
	_tween.set_trans(_trans_type)
	_tween.finished.connect(_on_done)
	return _tween

func _on_done():
	done.emit()
