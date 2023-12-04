extends Node

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
@export var ear_exchange_rate_resource: ObservableResource
@export var current_buy_offers_resource: ObservableResource

var unit_cam_scenes: Array[PackedScene] = []
var building_cam_scenes: Array[PackedScene] = []

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
	day_number_resource.value_changed.connect(_day_number_changed)
	call_deferred("_day_number_changed", 0, 0)

func _day_number_changed(day_number,_old):
	_create_offers(5, day_number, players_resource.value.size(), buildings_resource.value.size(), MoneyManager.I.get_resource(MoneyManager.MoneyType.Gold), MoneyManager.I.get_resource(MoneyManager.MoneyType.Ear))

func _create_offers(number_to_offer:int, day: int, player_count: int, building_count: int, player_money: int, player_ears: int):
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
	
	var offers: Array[Offer] = []
	
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
		
		offers.append(offer)
	current_buy_offers_resource.value = offers
