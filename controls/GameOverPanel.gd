extends UIPopup

class_name GameOverPanel

@onready var text: RichTextLabel = $"Panel/MarginContainer/VBoxContainer/Panel/ScrollContainer/VBoxContainer/MarginContainer/RichTextLabel"

func open(todo_list: TodoList):
	text.append_text(StatTracker.I.final_calc_and_save())
	get_tree().paused = true
	super.open(todo_list)

func close(todo_list: TodoList):
	get_tree().paused = false
	super.close(todo_list)

func try_again():
	get_tree().paused = false
	SceneManager.load_loading_scene(get_tree())

func main_menu():
	SceneManager.load_main_menu(get_tree())

#ignore click outs
func click_out() -> bool:
	return false
