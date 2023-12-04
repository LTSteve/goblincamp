extends Node

class_name Transition

@export var transition_on_ready: bool = true
@export var transition_on_close: bool = false

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
var _in_progress: bool = false

var _parent
var _trans_start
var _trans_end

func _ready():
	_parent = get_parent()
	var current_value = _parent.get(property_to_transition)
	_trans_start = transition_property_start.get_value() if !start_at_current_value else current_value
	_trans_end = transition_property_end.get_value() if !end_at_current_value else current_value
	
	if transition_on_ready: call_deferred("start_transition")

func start_transition():
	_in_progress = true
	
	_parent.set(property_to_transition, _trans_start)
	
	if delay_time > 0:
		call_deferred("_delay_transition")
	else:
		_do_transition()

func to_todo() -> TodoListItem:
	return TodoListItem.new(func(todo_list:TodoList):
		on_finished.connect(func(): todo_list.mark_step_done())
		if !_in_progress: start_transition()
	)

func _delay_transition():
	Wait.timer(delay_time, _parent, _do_transition)

func _do_transition():
	_reset_tween()
	_tween.tween_property(_parent,property_to_transition,_trans_end,transition_time)
	_tween.finished.connect(_finish_transition)

func _finish_transition():
	_in_progress = false
	on_finished.emit()

func _reset_tween() -> Tween:
	if _tween:
		_tween.stop()
		_tween = null
	_tween = get_parent().create_tween()
	_tween.set_ease(ease_type)
	_tween.set_trans(transition_type)
	return _tween
