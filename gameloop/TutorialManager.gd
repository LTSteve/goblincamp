extends Node

class_name TutorialManager

const cfg_file_name: StringName = "user://tutorial.cfg"
const TUTORIAL: StringName = "TUTORIAL"

const WELCOME: StringName = "WELCOME"
const MERCHANT: StringName = "MERCHANT"

var cfg_file:ConfigFile

var clear_tutorial_setting: SettingResource

@export_group("Observables")
@export_group("Inverse Signal Buses")
@export var todo_before_merchant_resource: InverseSignalBus

func _ready():
	cfg_file = ConfigFile.new()
	if cfg_file.load(cfg_file_name) == ERR_FILE_CANT_OPEN:
		printerr("Couldn't open tutorial cfg!")
	
	todo_before_merchant_resource.bind(_get_open_tutorial_as_todo.bind(MERCHANT))
	
	if !has_been_tutorialized(WELCOME):
		call_deferred("open_tutorial", WELCOME)

func _get_open_tutorial_as_todo(tutorial_key: StringName):
	return TodoListItem.new(func(todo:TodoList):
		if has_been_tutorialized(tutorial_key):
			todo.mark_step_done()
			return
		
		open_tutorial(tutorial_key, todo)
		)

func has_been_tutorialized(tutorial_key: StringName) -> bool:
	return cfg_file.has_section_key(TUTORIAL, tutorial_key)

func mark_tutorial_done(tutorial_key: StringName):
	cfg_file.set_value(TUTORIAL, tutorial_key, true)
	cfg_file.save(cfg_file_name)

func open_tutorial(tutorial_key: StringName, todo:TodoList = null):
	var tutorial := DB.I.tutorials[tutorial_key] as TutorialResource
	if tutorial:
		#open tutorial
		if todo: tutorial.finished.connect(func(): todo.mark_step_done())
		tutorial.finished.connect(mark_tutorial_done.bind(tutorial_key))
		var dialogue_popup: DialoguePanel = DB.I.scenes.dialogue_panel_scene.instantiate()
		dialogue_popup.initialize(tutorial)
		HUD.I.on_popup_open(dialogue_popup)
	else:
		if todo: tutorial.finished.connect(func(): todo.mark_step_done())
