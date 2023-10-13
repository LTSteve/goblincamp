extends Node

class_name ModifierManager

static var _I: ModifierManager

@export var test_card: CardResource

@export var blacksmith_deck: DeckResource
@export var leatherworker_deck: DeckResource
@export var enchanter_deck: DeckResource

func _ready():
	_I = self

static func apply_unit_modifiers(unit:Unit):
	for modifier in _I.get_children():
		(modifier as CardModifier).apply_to_unit(unit)

static func apply_modifier(resource:CardResource) -> CardModifier:
	var active_modifiers = _I.get_children()
	var current_modifier: CardModifier = null
	for mod in active_modifiers:
		if mod.get_script() == resource.card_script:
			current_modifier = mod as CardModifier
			break
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
	
	var ultra_rare: CardResource
	var rare: Array[CardResource] = []
	var normal: Array[CardResource] = []
	
	if cards.any(_I._match_ultra_rare_card):
		ultra_rare = _I._find_and_remove(cards, _I._match_ultra_rare_card)
	else:
		if cards.any(_I._match_rare_card):
			ultra_rare = _I._find_and_remove(cards, _I._match_rare_card)
		else:
			ultra_rare = _I._find_and_remove(cards, _I._match_normal_card)
	
	for i in 2:
		if cards.any(_I._match_rare_card):
			rare.append(_I._find_and_remove(cards, _I._match_rare_card))
		else:
			rare.append(_I._find_and_remove(cards, _I._match_normal_card))
	
	for i in 3:
		normal.append(_I._find_and_remove(cards, _I._match_normal_card))
	
	var r = randf()
	
	if r < 0.4:
		#three basic cards
		return normal
	elif r < 0.8:
		#two rare one basic
		return rare + [normal[0]]
	else:
		#one ultra rare, two rare
		return [ultra_rare] + rare
	

#cant make these static or they won't work as Callables

func _find_and_remove(array:Array,matcher:Callable):
	var found = null
	var index = -1
	var i = 0
	for element in array:
		if matcher.call(element):
			found = element
			index = i
			break
		i += 1
	if index != -1:
		pass #array.remove_at(index)
	return found

func _get_first_or_null(array:Array, matcher:Callable):
	for element in array:
		if matcher.call(element):
			return element
	return null

func _match_ultra_rare_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.UltraRare
func _match_rare_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.Rare
func _match_normal_card(card_resource:CardResource) -> bool:
	return card_resource.rarity == CardResource.CardRarity.Normal

func _match_unfinished_cards(card_resource:CardResource)->bool:
	#always allow infinite cards
	if card_resource.max_rank == 0: return true
	var children = _I.get_children()
	var existing_card = _get_first_or_null(children, func(card_modifier:CardModifier): return card_modifier.card_resource == card_resource) as CardModifier
	if existing_card && existing_card.current_rank >= card_resource.max_rank:
		return false
	return true
