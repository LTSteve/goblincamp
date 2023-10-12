extends Node

class_name CardModifier

@export var card_resource: CardResource
@export var current_rank: int = 0

func _ready():
	var data = card_resource.card_script_params.data if card_resource else {}
	_initialize(data)
	var active_units = (Global.enemies if card_resource.include_enemies else []) + (Global.players if card_resource.include_players else [])
	for unit in active_units:
		apply_to_unit(unit)

func apply_to_unit(unit:Unit):
	if (unit.is_enemy && !card_resource.include_enemies) || (!unit.is_enemy && !card_resource.include_players):
		return
	for type in card_resource.apply_to:
		var all_of_type = unit.find_children("", type)
		for instance in all_of_type:
			_apply(instance)

#override
func _initialize(_data):
	pass
#override
func _apply(_node):
	pass
