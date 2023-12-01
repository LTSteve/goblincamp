extends Control

class_name HUD

static var I: HUD

@onready var hide_on_popup: Control = $"HideOnPopup"
@onready var click_blocker: Panel = $"ClickBlocker"
@onready var popup_holder: Control = $"../PopupHolder"

var _tween: Tween
var _current_popup: UIPopup

func _ready():
	I = self

func on_pause():
	var pause_popup = DB.I.scenes.pause_panel_scene.instantiate()
	on_popup_open(pause_popup)

func on_popup_open(popup:UIPopup):
	hide_on_popup.visible = false
	click_blocker.visible = true
	_set_up_tween()
	_tween.tween_property(click_blocker, "modulate", Color(Color.WHITE, 1), 0.2)
	_current_popup = popup
	popup_holder.add_child(_current_popup)
	_current_popup.open()
	_current_popup.popup_close.connect(on_popup_close)

func on_popup_close():
	_set_up_tween()
	_tween.tween_property(click_blocker, "modulate", Color(Color.WHITE, 0), 0.2)
	if !_tween.finished.is_connected(_show_hud):
		_tween.finished.connect(_show_hud)

func _show_hud():
	_tween = null
	hide_on_popup.visible = true
	click_blocker.visible = false
	if _current_popup:
		_current_popup.queue_free()
		_current_popup = null

func _set_up_tween():
	if _tween:
		_tween.stop()
		_tween = null
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)

# for click-outs
func _on_click_blocker_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_current_popup.click_out()
