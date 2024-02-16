extends Control

class_name UIPopup

signal popup_close()

signal popup_done()

var close_transitions: Array[Transition] = []
var open_transitions: Array[Transition] = []

func open(todo_list:TodoList):
	_load_transitions()
	
	if open_transitions.size() == 0:
		todo_list.mark_step_done()
		return
	
	var todo = []
	for trans: Transition in open_transitions:
		todo.append(trans.to_todo())
	
	TodoList.new(todo, true).on_done(func():todo_list.mark_step_done())

func finish_open():
	pass

func finish_close():
	pass

func close(todo_list:TodoList):
	popup_done.emit()
	
	if close_transitions.size() == 0:
		_wrap_up(todo_list)
		return
	
	var todo = []
	for trans: Transition in close_transitions:
		todo.append(trans.to_todo())
	
	TodoList.new(todo, true).on_done(_wrap_up.bind(todo_list))

func _load_transitions():
	var transitions = find_children("", "Transition")
	for t:Transition in transitions:
		if t.transition_on_ready:
			open_transitions.append(t)
		if t.transition_on_close:
			close_transitions.append(t)

func _wrap_up(todo_list):
	todo_list.mark_step_done()
	finish_close()
	queue_free()

func click_out() -> bool:
	return true

func click_blocker() -> bool:
	return true
