extends Node

class_name ModifierManager

static var _I: ModifierManager

@export var test_card: CardResource

func _ready():
	_I = self

func _on_spawn_building(building_type:UnitSpawner.BuildingType):
	var instance = Node.new()
	instance.set_script(test_card.card_script)
	var card_modifier = (instance as CardModifier)
	card_modifier.card_resource = test_card
	card_modifier.current_rank = 1
	add_child(card_modifier)
	


static func apply_unit_modifiers(unit:Unit):
	for modifier in _I.get_children():
		(modifier as CardModifier).apply_to_unit(unit)
