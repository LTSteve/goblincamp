extends Node

class_name HideOnTrue

@export var this:Node

@export var observable_pattern: Observable

func _ready():
	observable_pattern.ready()
	observable_pattern.value_changed.connect(_on_change)
	this.visible = !observable_pattern.get_value()

func _on_change(new_value,_old_value):
	this.visible = !new_value

func _exit_tree():
	observable_pattern.value_changed.disconnect(_on_change)
