extends Control

class_name UIPopup

signal popup_close()

func open(todo_list:TodoList):
	todo_list.mark_step_done()

func finish_open():
	pass

func close(todo_list:TodoList):
	todo_list.mark_step_done()
	queue_free()

func click_out() -> bool:
	return true
