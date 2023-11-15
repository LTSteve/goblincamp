extends Button

@export var is_day_resource: ObservableResource

func _ready():
	is_day_resource.value_changed.connect(_on_day_changed)

func _on_day_changed(is_day, _was_day):
	visible = is_day

func _on_purchase_made():
	visible = true

#have to bind to this directly so you can't double-click the boy
func _on_pressed():
	visible = false
