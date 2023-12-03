extends UIPopup

class_name BuyPanel

@onready var container:Container = $"BuyPanel/MarginContainer/Offers/ScrollContainer/MarginContainer/FlowContainer"
@onready var scroll_container: ScrollContainer = $"BuyPanel/MarginContainer/Offers/ScrollContainer"

@export var available_unit_types: Array[UnitSpawner.UnitType]
@export var available_building_types: Array[UnitSpawner.BuildingType]

@export var unit_costs: Array[int]
@export var building_costs: Array[int]

@export var random_price_varience: float = 0.1
@export var bulk_discount: float = 0.01

@export_group("Observable")
@export var day_number_resource: ObservableResource
@export var players_resource: ObservableResource
@export var buildings_resource: ObservableResource
@export var has_made_purchase_resource: ObservableResource
@export var ear_exchange_rate_resource: ObservableResource

var unit_cam_scenes: Array[PackedScene] = []
var building_cam_scenes: Array[PackedScene] = []

var _current_offers: Array[Offer] = []

func _ready():
	unit_cam_scenes = [
		DB.I.scenes.knight_unit_cam,
		DB.I.scenes.witch_unit_cam,
		DB.I.scenes.woodsman_unit_cam,
		DB.I.scenes.bearkin_unit_cam,
	]
	
	building_cam_scenes = [
		DB.I.scenes.blacksmith_cam,
		DB.I.scenes.leatherworker_cam,
		DB.I.scenes.enchanter_cam,
		DB.I.scenes.tavern_cam,
	]

func open(todo_list:TodoList):
	if _current_offers.is_empty():
		_setup_offers()
	scroll_container.scroll_vertical = 0
	super.open(todo_list)

func close(todo_list:TodoList):
	CameraRig.I.unset_camera_angle_override()
	super.close(todo_list)

func _setup_offers():
	_create_offers(5, day_number_resource.value, players_resource.value.size(), buildings_resource.value.size(), MoneyManager.I.get_resource(MoneyManager.MoneyType.Gold), MoneyManager.I.get_resource(MoneyManager.MoneyType.Ear))
	_create_offer_display()

func _create_offers(number_to_offer:int, day: int, player_count: int, building_count: int, player_money: int, player_ears: int):
	_current_offers = []
	
	var can_buy_buildings = day > 0
	
	@warning_ignore("integer_division")
	var building_split_number: int = (number_to_offer / 2) if can_buy_buildings else number_to_offer
	
	var current_bulk_discount: float = bulk_discount if player_count < (day * 6) else (bulk_discount / 2)
	var ear_exchange_rate = ear_exchange_rate_resource.value
	var value = player_money + player_ears * ear_exchange_rate
	value = (value * 0.05) if value > 1000 else 0
	
	var target_spawn_power = GameManager.I.get_spawn_power(day+1)
	
	var effective_player_count = ((value / 100.0) + player_count) as int
	
	var scl:float = 0
	if effective_player_count < target_spawn_power || day <= 1:
		scl = .75
	elif effective_player_count < (target_spawn_power + 5):
		scl = 1
	elif effective_player_count < (target_spawn_power + 10):
		scl = 1.3
	else:
		scl = 2.0
	
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
		offer.model_scene_1 = unit_cam_scenes[indexes[0]]
		offer.type_1_count = randi_range(low_unit_offer, high_unit_offer)
		
		if number > building_split_number:
			indexes[1] = range(available_building_types.size()).pick_random()
			offer.type_2_is_building = true
			offer.building_type_2 = available_building_types[indexes[1]]
			offer.model_scene_2 = building_cam_scenes[indexes[1]]
			offer.type_2_count = 1
		else:
			offer.unit_type_2 = available_unit_types[indexes[1]]
			offer.model_scene_2 = unit_cam_scenes[indexes[1]]
			offer.type_2_count = randi_range(low_unit_offer, high_unit_offer)
		
		var base_price = unit_costs[indexes[0]] * offer.type_1_count + (building_costs[indexes[1]] if offer.type_2_is_building else unit_costs[indexes[1]]) * offer.type_2_count
		var random_varience = 1.0 + randf() * random_price_varience
		var discount = 1.0 - (offer.type_1_count + offer.type_2_count) * current_bulk_discount
		offer.price = ((value + base_price * discount) * random_varience * scl)
		if day <= 1:
			offer.price = min(offer.price, 500)
		
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
