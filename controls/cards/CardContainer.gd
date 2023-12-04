@tool

extends Node3D

class_name CardContainer

@onready var trans_in: Transition = $"TransitionIn"
@onready var trans_out: Transition = $"TransitionOut"

@export var re_render: bool:
	set(_value):
		re_render = false
		tween_into_position()

var _selected_index = 0

var _cards: Array[CardDisplay] = []

func initialize():
	var cards = get_children()
	
	for i in cards.size():
		if !(cards[i] is CardDisplay): continue
		cards[i].position = _get_position_of_card(i)
		_cards.append(cards[i])
	
	_selected_index = 0
	trans_in.start_transition()
	tween_into_position()

func tween_into_position():
	for i in _cards.size():
		var card := _cards[i]
		
		if Engine.is_editor_hint():
			card.position = _get_position_of_card(i)
			continue
		
		var key = [card,"__tween"]
		
		var tween: Tween = UniqueMetaId.retrieve(key)
		if tween:
			tween.stop()
		
		tween = card.create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(card, "position", _get_position_of_card(i), 0.2)
		UniqueMetaId.store(key, tween)
	
	var active_card := get_active_card()
	if active_card.hidden:
		active_card.flip()

func _get_position_of_card(index: int) -> Vector3:
	var actual_index = index - _selected_index
	
	var x_index = actual_index * 8
	var x = sqrt(abs(x_index)) * sign(actual_index)
	
	var y = abs(actual_index)
	
	return Vector3(-y, 0, -x)

func shift_to(index):
	_selected_index = clampi(index, 0, _cards.size() - 1)
	tween_into_position()

func clear():
	trans_out.on_finished.connect(func():
		for card:CardDisplay in _cards:
			card.queue_free()
		_cards = []
	)
	trans_out.start_transition()

func get_active_card() -> CardDisplay:
	return _cards[_selected_index]

func shift_left():
	shift_to(_selected_index - 1)

func shift_right():
	shift_to(_selected_index + 1)
