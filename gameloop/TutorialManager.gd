extends Node

class_name TutorialManager

const cfg_file_name: StringName = "user://tutorial.cfg"
const TUTORIAL: StringName = "TUTORIAL"

const WELCOME: StringName = "WELCOME"
const MERCHANT: StringName = "MERCHANT"
const EARS: StringName = "EARS"
const ENEMIES_GROW: StringName = "ENEMIES_GROW"
const WIZARD: StringName = "WIZARD"

var cfg_file:ConfigFile

var clear_tutorial_setting: SettingResource

@export_group("Observables")
@export var ear_count_resource: ObservableResource
@export var is_day_resource: ObservableResource
@export_group("Inverse Signal Buses")
@export var todo_before_merchant_resource: InverseSignalBus
@export var todo_before_goblin_power_resource: InverseSignalBus

func _ready():
	cfg_file = ConfigFile.new()
	if cfg_file.load(cfg_file_name) == ERR_FILE_CANT_OPEN:
		printerr("Couldn't open tutorial cfg!")
	
	is_day_resource.value_changed.connect(func(new_value, _old_value):
		if new_value && WizardBehaviour.is_wizard_active() && !has_been_tutorialized(WIZARD): open_tutorial(WIZARD)
		)
	
	ear_count_resource.value_changed.connect(func(_new_value, _old_value): 
		if !has_been_tutorialized(EARS): open_tutorial(EARS)
		, CONNECT_ONE_SHOT)
	
	todo_before_merchant_resource.bind(_get_open_tutorial_as_todo.bind(MERCHANT))
	
	todo_before_goblin_power_resource.bind(_get_open_tutorial_as_todo.bind(ENEMIES_GROW))
	
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
