extends Control

class_name HUD

static var I: HUD

@onready var hide_on_popup: Control = $"HideOnPopup"
@onready var click_blocker: Panel = $"ClickBlocker"
@onready var popup_holder: Control = $"../PopupHolder"

var _tween_modulate: Tween
var _current_popup: UIPopup

func _ready():
	I = self

func on_pause():
	var pause_popup = DB.I.scenes.pause_panel_scene.instantiate()
	on_popup_open(pause_popup)

func on_popup_open(popup:UIPopup):
	var todo_tasks = []
	
	_hide_hud()
	
	if is_instance_valid(_current_popup):
		todo_tasks.append(TodoListItem.new(_current_popup.close))
	
	todo_tasks.append(TodoListItem.new(_fade_in_click_blocker if popup.click_blocker() else _fade_out_click_blocker))
	
	_current_popup = popup
	_current_popup.popup_close.connect(on_popup_close)
	popup_holder.add_child(_current_popup)
	
	todo_tasks.append(TodoListItem.new(_current_popup.open))
	
	TodoList.new(todo_tasks,true).on_done(_current_popup.finish_open)

#only called when the popup is simply being closed (popup replacements handled above)
func on_popup_close():
	var todo = [TodoListItem.new(_current_popup.close), TodoListItem.new(_fade_out_click_blocker)]
	TodoList.new(todo, true).on_done(_show_hud)

func _hide_hud():
	hide_on_popup.visible = false
	click_blocker.visible = true

func _show_hud():
	hide_on_popup.visible = true
	click_blocker.visible = false

func _set_up_tween():
	if _tween_modulate:
		_tween_modulate.stop()
		_tween_modulate = null
	_tween_modulate = create_tween()
	_tween_modulate.set_ease(Tween.EASE_IN_OUT)

func _fade_out_click_blocker(todo_list:TodoList):
	_set_up_tween()
	_tween_modulate.tween_property(click_blocker, "modulate", Color(Color.WHITE, 0), 0.2)
	_tween_modulate.finished.connect(todo_list.mark_step_done)

func _fade_in_click_blocker(todo_list:TodoList):
	_set_up_tween()
	_tween_modulate.tween_property(click_blocker, "modulate", Color(Color.WHITE, 1), 0.2)
	_tween_modulate.finished.connect(todo_list.mark_step_done)

# for click-outs
func _on_click_blocker_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		if _current_popup.click_out(): _current_popup.popup_close.emit()
