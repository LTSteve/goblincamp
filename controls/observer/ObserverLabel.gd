extends Label

class_name ObserverLabel

@export var template_string: String = ""
@export var observable_resource: Observable

var _template: String

func _ready():
	observable_resource.ready()
	
	_template = template_string if template_string.contains("%") else template_string + "%s"
	_set_label()
	observable_resource.value_changed.connect(_on_value_changed)

func _on_value_changed(_v,_ov):
	_set_label()

func _set_label():
	text = _template % observable_resource.get_value()
