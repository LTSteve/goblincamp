extends Button

class_name OpenDisenchantButton

static var I: OpenDisenchantButton

@export var is_day_resource: ObservableResource

func _ready():
	I = self

func enable():
	is_day_resource.value_changed.connect(_on_day_changed)

func _on_day_changed(is_day, _was_day):
	visible = is_day

