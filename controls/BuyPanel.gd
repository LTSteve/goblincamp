extends TweenSlide

class_name BuyPanel

static var I: BuyPanel

signal purchase_made()

@onready var container:Container = $"BuyPanel/MarginContainer/Offers/ScrollContainer/MarginContainer/FlowContainer"
@onready var scroll_container: ScrollContainer = $"BuyPanel/MarginContainer/Offers/ScrollContainer"

@export var available_unit_types: Array[UnitSpawner.UnitType]
@export var available_building_types: Array[UnitSpawner.BuildingType]

@export var unit_viewports: Array[SubViewport]
@export var building_viewports: Array[SubViewport]

@export var unit_costs: Array[int]
@export var building_costs: Array[int]

@export var random_price_varience: float = 0.1
@export var bulk_discount: float = 0.01

var _current_offers: Array[Offer] = []

func _ready():
	I = self
	super._ready()

func slide_in():
	if _current_offers.is_empty():
		_on_day()
	scroll_container.scroll_vertical = 0
	super.slide_in()

func slide_out():
	CameraRig.I.unset_camera_angle_override()
	super.slide_out()

func _on_day():
	_create_offers(5, GameManager.I.get_day(), Global.players.size(), Global.buildings.size(), MoneyManager.I.get_resource(MoneyManager.MoneyType.Gold))
	_create_offer_display()

func _create_offers(number_to_offer:int, day: int, player_count: int, building_count: int, player_money: int):
	_current_offers = []
	
	var can_buy_buildings = day > 0
	
	@warning_ignore("integer_division")
	var building_split_number: int = (number_to_offer / 2) if can_buy_buildings else number_to_offer
	
	var current_bulk_discount: float = bulk_discount if player_count < day * 6 else (bulk_discount / 2)
	var low_money_discount: float = 1.0 if player_money > 1000 else 0.75
	
	if can_buy_buildings:
		if player_count > day * 5:
			building_split_number -= 1
		@warning_ignore("integer_division")
		var day_over_2 = day / 2
		if building_count > day_over_2:
			building_split_number += 1
	
	var low_unit_offer = 1 if day < 10 else 2
	var high_unit_offer = 2 if day < 10 else 6
	
	for number in number_to_offer:
		var indexes = range(available_unit_types.size())
		indexes.shuffle()
		
		var offer = Offer.new()
		offer.unit_type_1 = available_unit_types[indexes[0]]
		offer.viewport_texture_1 = unit_viewports[indexes[0]].get_texture()
		offer.type_1_count = randi_range(low_unit_offer, high_unit_offer)
		
		if number > building_split_number:
			indexes[1] = range(available_building_types.size()).pick_random()
			offer.type_2_is_building = true
			offer.building_type_2 = available_building_types[indexes[1]]
			offer.viewport_texture_2 = building_viewports[indexes[1]].get_texture()
			offer.type_2_count = 1
		else:
			offer.unit_type_2 = available_unit_types[indexes[1]]
			offer.viewport_texture_2 = unit_viewports[indexes[1]].get_texture()
			offer.type_2_count = randi_range(low_unit_offer, high_unit_offer)
		
		var base_price = unit_costs[indexes[0]] * offer.type_1_count + (building_costs[indexes[1]] if offer.type_2_is_building else unit_costs[indexes[1]]) * offer.type_2_count
		var random_varience = 1.0 + randf() * random_price_varience
		var discount = 1.0 - (offer.type_1_count + offer.type_2_count) * current_bulk_discount
		offer.price = base_price * random_varience * discount * low_money_discount
		
		offer.name = Offer.random_name()
		
		_current_offers.append(offer)

func _create_offer_display():
	var offer_display_scene:PackedScene = DB.I.scenes.offer_display_scene
	
	for child in container.get_children():
		child.queue_free()
	
	for offer in _current_offers:
		var new_offer = offer_display_scene.instantiate() as OfferDisplay
		new_offer.offer = offer
		container.add_child(new_offer)
		
		new_offer.price_button.pressed.connect(_on_purchase_button_pressed.bind(offer, new_offer))

func _on_purchase_button_pressed(offer:Offer, offer_display:OfferDisplay):
	if MoneyManager.I.try_spend(offer.price):
		offer_display.disable()
		purchase_made.emit()
		
		for _i in offer.type_1_count:
			UnitSpawner.I.spawn_friendly(offer.unit_type_1)
		if offer.type_2_is_building:
			PickProjectModel.I.open(offer.building_type_2)
			slide_out()
		else:
			for _i in offer.type_2_count:
				UnitSpawner.I.spawn_friendly(offer.unit_type_2)

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		slide_out()
