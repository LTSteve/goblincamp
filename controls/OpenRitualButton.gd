extends Button

@export var wizard: Unit

func _pressed():
	if ! wizard: return
	WizardBehaviour.open_buy_panel(wizard)

func _on_night(_day):
	visible = false

func _on_day():
	if WizardBehaviour.is_wizard_active():
		visible = true
