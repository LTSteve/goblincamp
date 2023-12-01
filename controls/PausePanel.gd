extends UIPopup

@onready var settings_menu: SettingsMenu = $SettingsMenu

func open(todo_list: TodoList):
	get_tree().paused = true
	super.open(todo_list)

func close(todo_list: TodoList):
	get_tree().paused = false
	super.close(todo_list)

func quit():
	SceneManager.load_main_menu(get_tree())
