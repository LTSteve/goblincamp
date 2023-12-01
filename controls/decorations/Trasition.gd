extends Node

class_name Transition

@export var transition_on_ready: bool = true

@export var property_to_transition: String
@export var transition_time: float = 0.2
@export var delay_time: float = 0

@export var start_at_current_value: bool = false
@export var transition_property_start: TransitionProperty
@export var end_at_current_value: bool = false
@export var transition_property_end: TransitionProperty

@export var ease_type: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition_type: Tween.TransitionType = Tween.TRANS_LINEAR

signal on_finished()

var _tween: Tween

func _ready():
	if ! transition_on_ready: return
	start_transition()

func start_transition():
	var parent = get_parent()
	var current_value = parent.get(property_to_transition)
	
	var trans_start = transition_property_start.get_value() if !start_at_current_value else current_value
	var trans_end = transition_property_end.get_value() if !end_at_current_value else current_value
	
	parent.set(property_to_transition, trans_start)
	
	if delay_time > 0:
		call_deferred("_delay_transition", parent, trans_end)
	else:
		_do_transition(parent,trans_end)

func _delay_transition(parent:Node, trans_end):
	Wait.timer(delay_time, parent, _do_transition.bind(parent,trans_end))

func _do_transition(parent:Node, trans_end):
	_reset_tween()
	_tween.tween_property(parent,property_to_transition,trans_end,transition_time)

func _reset_tween() -> Tween:
	if _tween:
		_tween.stop()
		_tween = null
	_tween = get_parent().create_tween()
	_tween.set_ease(ease_type)
	_tween.set_trans(transition_type)
	return _tween
