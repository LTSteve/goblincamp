extends UIPopup

class_name DialoguePanel

@onready var texture_rect_left: TextureRect3D = $"Panel/HBoxContainer/3DTextureRect_left"
@onready var texture_rect_right: TextureRect3D = $"Panel/HBoxContainer/3DTextureRect_right"
@onready var dialogue_text: TypeWriter = $"Panel/HBoxContainer/MarginContainer/Panel/MarginContainer/Label/TypeWriter"
@onready var speaker_name_text: Label = $"Panel/CenterContainer/Label"

var tutorial: TutorialResource

var _current_tutorial_step:int = -1
var _current_tutorial: TutorialDialogue

func _set_current_tutorial(step:int):
	_current_tutorial_step = step
	_current_tutorial = tutorial.tutorial_dialogues[step]
	
	if _current_tutorial.portrait_scene:
		if _current_tutorial.portrait_right:
			texture_rect_left.visible = false
			texture_rect_right.visible = true
			texture_rect_right.model_scene = _current_tutorial.portrait_scene
			texture_rect_right.initialize()
		else:
			texture_rect_right.visible = false
			texture_rect_left.visible = true
			texture_rect_left.model_scene = _current_tutorial.portrait_scene
			texture_rect_left.initialize()
	else:
			texture_rect_right.visible = false
			texture_rect_left.visible = false
	
	dialogue_text.set_text(_current_tutorial.dialogue)
	
	if _current_tutorial.speaker_name:
		speaker_name_text.text = " %s " % _current_tutorial.speaker_name
		speaker_name_text.visible = true
	else:
		speaker_name_text.visible = false

func initialize(t:TutorialResource):
	tutorial = t

func open(todo_list:TodoList):
	_set_current_tutorial(0)
	super.open(todo_list)

func close(todo_list:TodoList):
	CameraRig.I.unset_camera_angle_override()
	super.close(todo_list)

func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()

func _on_click():
	if dialogue_text.is_typing():
		dialogue_text.hurry()
		return
	
	var next_tutorial_step = _current_tutorial_step + 1
	if tutorial.tutorial_dialogues.size() <= next_tutorial_step:
		popup_close.emit()
		tutorial.finished.emit()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		_set_current_tutorial(next_tutorial_step)
