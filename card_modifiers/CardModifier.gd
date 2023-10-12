extends Node

class_name CardModifier

@export var card_resource: CardResource
@export var current_rank: int = 0

func _ready():
	var data = card_resource.card_script_params.data if card_resource && card_resource.card_script_params else {}
	_initialize(data)

func rank_up():
	var active_units = (Global.enemies if card_resource.include_enemies else []) + (Global.players if card_resource.include_players else [])
	if current_rank > 0:
		for unit in active_units:
			un_apply_to_unit(unit)
	current_rank += 1
	for unit in active_units:
		apply_to_unit(unit)

func derank():
	var active_units = (Global.enemies if card_resource.include_enemies else []) + (Global.players if card_resource.include_players else [])
	for unit in active_units:
		un_apply_to_unit(unit)
	current_rank -= 1
	if current_rank == 0:
		queue_free()
	else:
		for unit in active_units:
			apply_to_unit(unit)

func apply_to_unit(unit:Unit):
	if (unit.is_enemy && !card_resource.include_enemies) || (!unit.is_enemy && !card_resource.include_players):
		return
	for type in card_resource.apply_to:
		var all_of_type = unit.find_children("", type)
		for instance in all_of_type:
			if !card_resource.group_filters || card_resource.group_filters.size() == 0 || card_resource.group_filters.any(instance.is_in_group):
				_apply(instance,unit)

func un_apply_to_unit(unit:Unit):
	if (unit.is_enemy && !card_resource.include_enemies) || (!unit.is_enemy && !card_resource.include_players):
		return
	for type in card_resource.apply_to:
		var all_of_type = unit.find_children("", type)
		for instance in all_of_type:
			if !card_resource.group_filters || card_resource.group_filters.size() == 0 || card_resource.group_filters.any(instance.is_in_group):
				_un_apply(instance,unit)

#override
func _initialize(_data):
	pass
#override
func _apply(_node,_unit):
	pass
#override
func _un_apply(_node,_unit):
	pass
