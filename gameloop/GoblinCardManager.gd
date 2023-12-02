extends Node

class_name GoblinCardManager

static var I: GoblinCardManager

@export var first_modifier_night: int = 5
@export var modifier_interval: int = 10

@export_group("Observables")
@export var day_number_resource: Observable

@export_group("Inverse Signal Buses")
@export var todo_before_day_resource: InverseSignalBus

var _todo_list: TodoList

func _ready():
	I = self
	todo_before_day_resource.bind(_get_todo_before_day)

func _get_todo_before_day() -> TodoListItem:
	return TodoListItem.new(try_open)

func try_open(todo_list:TodoList):
	var day = day_number_resource.value + 1
	if day < GoblinCardManager.I.first_modifier_night || ((day - GoblinCardManager.I.first_modifier_night) % GoblinCardManager.I.modifier_interval) != 0: 
		todo_list.mark_step_done()
		return
	
	_todo_list = todo_list
	
	var goblin_panel = DB.I.scenes.goblin_card_panel_scene.instantiate() as GoblinCardPanel
	goblin_panel.popup_close.connect(func(): 
		_todo_list.mark_step_done()
		_todo_list = null)
	HUD.I.on_popup_open(goblin_panel)
