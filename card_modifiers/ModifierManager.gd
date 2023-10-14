extends Node

class_name ModifierManager

static var _I: ModifierManager

@export var test_card: CardResource

@export var blacksmith_deck: DeckResource
@export var leatherworker_deck: DeckResource
@export var enchanter_deck: DeckResource

func _ready():
	_I = self

static func get_modifier_by_resource(card_resource: CardResource, generate_default: bool = true):
	var active_modifiers = _I.get_children()
	for mod in active_modifiers:
		if mod.get_script() == card_resource.card_script:
			return mod as CardModifier
	if ! generate_default: return null
	var dummy_card_modifier = { 
		"current_rank": 0, 
		"card_resource": card_resource, 
		"params": card_resource.card_script_params.data
	}
	return dummy_card_modifier

static func apply_unit_modifiers(unit:Unit):
	for modifier in _I.get_children():
		(modifier as CardModifier).apply_to_unit(unit)

static func apply_modifier(resource:CardResource) -> CardModifier:
	var current_modifier = get_modifier_by_resource(resource, false)
	if !current_modifier:
		var instance = Node.new()
		instance.set_script(resource.card_script)
		current_modifier = (instance as CardModifier)
		current_modifier.card_resource = resource
		_I.add_child(current_modifier)
	current_modifier.rank_up()
	return current_modifier

static func un_apply_modifier(modifier:CardModifier):
	modifier.derank()

static func generate_card_choices(building_type: UnitSpawner.BuildingType) -> Array:
	var deck:DeckResource
	match building_type:
		UnitSpawner.BuildingType.Blacksmith:
			deck = _I.blacksmith_deck
		UnitSpawner.BuildingType.Leatherworker:
			deck = _I.leatherworker_deck
		UnitSpawner.BuildingType.Enchanter:
			deck = _I.enchanter_deck
	
	var cards = deck.get_cards().filter(_I._match_unfinished_cards)
	cards.shuffle()
	
	var infinite_normal = _I._find_and_remove_all(cards, _I._match_infinite_normal)
	
	var r = randf()
	
	if r < 0.4:
		#three basic cards
		return [
			_I._fall_through_find_and_remove(cards, [_I._match_normal_card, _I._match_rare_card, _I._match_ultra_rare_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_normal_card, _I._match_rare_card, _I._match_ultra_rare_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_normal_card, _I._match_rare_card, _I._match_ultra_rare_card], infinite_normal),
		]
	elif r < 0.8:
		#two rare one basic
		return [
			_I._fall_through_find_and_remove(cards, [_I._match_rare_card, _I._match_normal_card, _I._match_ultra_rare_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_rare_card, _I._match_normal_card, _I._match_ultra_rare_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_normal_card, _I._match_rare_card, _I._match_ultra_rare_card], infinite_normal),
		]
	else:
		#one ultra rare, two rare
		return [
			_I._fall_through_find_and_remove(cards, [_I._match_ultra_rare_card, _I._match_rare_card, _I._match_normal_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_rare_card, _I._match_normal_card, _I._match_ultra_rare_card], infinite_normal),
			_I._fall_through_find_and_remove(cards, [_I._match_rare_card, _I._match_normal_card, _I._match_ultra_rare_card], infinite_normal),
		]
	

#cant make these static or they won't work as Callables

func _fall_through_find_and_remove(array: Array, matchers: Array[Callable], fallback):
	for matcher in matchers:
		if array.any(matcher):
			return _I._find_and_remove(array, matcher)
	if fallback is Array:
		if fallback.size() == 0: return null
		return fallback[0] if fallback.size() == 1 else fallback[randi_range(0,fallback.size()-1)]
	else:
		return fallback

func _find_and_remove(array:Array,matcher:Callable):
	var found = null
	var to_remove:int = -1
	var i = 0
	for element in array:
		if matcher.call(element):
			found = element
			to_remove = i
			break
		i += 1
	if found:
		array.remove_at(to_remove)
	return found

func _find_and_remove_all(array:Array, matcher:Callable):
	var found: Array = []
	var to_remove:Array[int] = []
	var i = 0
	for element in array:
		if matcher.call(element):
			found.append(element)
			to_remove.append(i)
		i += 1
	for index in to_remove:
		array.remove_at(index)
	return found

func _get_first_or_null(array:Array, matcher:Callable):
	for element in array:
		if matcher.call(element):
			return element
	return null

func _match_infinite_normal(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.Normal && card_resource.max_rank == 0
func _match_ultra_rare_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.UltraRare
func _match_rare_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.Rare
func _match_normal_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.Normal

func _match_unfinished_cards(card_resource:CardResource)->bool:
	#always allow infinite cards
	if card_resource.max_rank == 0: return true
	var children = _I.find_children("", "CardModifier", false)
	var existing_card = _get_first_or_null(children, func(card_modifier:CardModifier): return card_modifier.card_resource == card_resource) as CardModifier
	if existing_card && existing_card.current_rank >= card_resource.max_rank:
		return false
	return true
