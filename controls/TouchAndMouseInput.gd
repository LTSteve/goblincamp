extends Node

class_name TouchAndMouseInput

static var I: TouchAndMouseInput

var _pressed: bool = false
var _dist: Vector2 = Vector2.ZERO

func _ready():
	I = self

func _input(event):
	var wasnt_pressed = !_pressed
	if event is InputEventMouseMotion:
		if wasnt_pressed:
			_dist = Vector2.ZERO
		else:
			_dist = event.relative
	
	if event is InputEventScreenTouch:
		_pressed = event.is_pressed()
		if !_pressed:
			_dist = Vector2.ZERO
	if event is InputEventMouseButton:
		_pressed = event.is_pressed()
		if !_pressed:
			_dist = Vector2.ZERO
	

func get_current_drag_v2():
	return _dist
