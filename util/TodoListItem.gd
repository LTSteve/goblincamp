class_name TodoListItem

var callable: Callable

func _init(c):
	callable = c

func execute(todo_list:TodoList):
	callable.call(todo_list)
