extends Button

@export var is_day_resource: ObservableResource

func _ready():
	is_day_resource.value_changed.connect(_on_day_changed)

func _pressed():
	WizardBehaviour.open_buy_panel()

func _on_day_changed(is_day, _was_day):
	visible = WizardBehaviour.is_wizard_active() if is_day else false
