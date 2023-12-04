extends Resource

class_name DeckResource

@export var card_folder_name: String

func get_cards() -> Array[CardResource]:
	var to_return: Array[CardResource] = []
	to_return.append_array(DB.I.resource_groups.get(card_folder_name))
	to_return = to_return.filter(func (card_resource:CardResource):
		return card_resource.unlocked;
	)
	return to_return
