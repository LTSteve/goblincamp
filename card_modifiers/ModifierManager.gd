extends Node

class_name ModifierManager

static var _I: ModifierManager

@export var test_card: CardResource

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
