@tool

extends Node3D

class_name CardContainer

@export var re_render: bool:
	set(_value):
		re_render = false
		tween_into_position()

var _selected_index = 0

func _ready():
	var cards = get_children()
	
	for i in cards.size():
		cards[i].position = _get_position_of_card(i)

func tween_into_position():
	var cards = get_children()
	
	for i in cards.size():
		var card = cards[i] as Node3D
		
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

func _get_position_of_card(index: int) -> Vector3:
	var actual_index = index - _selected_index
	
	var x_index = actual_index * 8
	var x = sqrt(abs(x_index)) * sign(actual_index)
	
	var y = abs(actual_index)
	
	return Vector3(-y, 0, -x)

func shift_to(index):
	_selected_index = index
	tween_into_position()

func get_active_card() -> CardDisplay:
	return get_children()[_selected_index]

func shift_left():
	shift_to(clampi(_selected_index - 1, 0, get_child_count() - 1))

func shift_right():
	shift_to(clampi(_selected_index + 1, 0, get_child_count() - 1))
