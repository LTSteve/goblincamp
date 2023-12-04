extends UIPopup

class_name BuyPanel

@onready var container:Container = $"BuyPanel/MarginContainer/Offers/ScrollContainer/MarginContainer/FlowContainer"
@onready var scroll_container: ScrollContainer = $"BuyPanel/MarginContainer/Offers/ScrollContainer"

@export_group("Observable")
@export var current_buy_offers_resource: ObservableResource
@export var has_made_purchase_resource: ObservableResource

func open(todo_list:TodoList):
	_create_offer_display()
	scroll_container.scroll_vertical = 0
	super.open(todo_list)

func close(todo_list:TodoList):
	CameraRig.I.unset_camera_angle_override()
	super.close(todo_list)

func _create_offer_display():
	var offer_display_scene:PackedScene = DB.I.scenes.offer_display_scene
	var current_offers = current_buy_offers_resource.get_value()
	
	for child in container.get_children():
		child.queue_free()
	
	for offer:Offer in current_offers:
		var new_offer = offer_display_scene.instantiate() as OfferDisplay
		new_offer.offer = offer
		container.add_child(new_offer)
		
		new_offer.price_button.pressed.connect(_on_purchase_button_pressed.bind(offer, new_offer))

func _on_purchase_button_pressed(offer:Offer, offer_display:OfferDisplay):
	if MoneyManager.I.try_spend(offer.price):
		offer_display.disable()
		offer.available = false
		has_made_purchase_resource.value = true
		
		for _i in offer.type_1_count:
			UnitSpawner.I.spawn_friendly(offer.unit_type_1)
		
		if offer.type_2_is_building:
			
			var pick_project_modal: PickProjectModel = DB.I.scenes.pick_project_scene.instantiate()
			pick_project_modal.generate_building_cards(offer.building_type_2)
			pick_project_modal.on_building_card_selected.connect(UnitSpawner.I.spawn_building)
			HUD.I.on_popup_open(pick_project_modal)
		else:
			for _i in offer.type_2_count:
				UnitSpawner.I.spawn_friendly(offer.unit_type_2)
