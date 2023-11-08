extends Button

@export var merchant: Unit

func _pressed():
	MerchantBehaviour.open_buy_panel(merchant)

func _on_night(_day):
	visible = false
