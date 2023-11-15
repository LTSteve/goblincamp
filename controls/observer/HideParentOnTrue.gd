extends Node

class_name HideParentOnMatch

@export var observable_pattern: Observable

var _parent

func _ready():
	observable_pattern.ready()
	_parent = get_parent()
	observable_pattern.value_changed.connect(_on_change)

func _on_change(new_value,_old_value):
	_parent.visible = !new_value
