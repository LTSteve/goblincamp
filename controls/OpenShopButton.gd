extends Button

@export var is_day_resource: ObservableResource

func _ready():
	is_day_resource.value_changed.connect(_on_day_changed)

func _pressed():
	MerchantBehaviour.open_buy_panel()

func _on_day_changed(is_day, _was_day):
	visible = is_day
