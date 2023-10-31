extends Resource

class_name DeckResource

@export var card_folder_name: String

func get_cards():
	return DB.I.resource_groups.get(card_folder_name)
