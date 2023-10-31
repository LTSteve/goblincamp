extends Resource

class_name DeckResource

@export_dir var card_folder: String

var _cached_cards: Array[CardResource]

func get_cards(cached_ok:bool = false) -> Array[CardResource]:
	if cached_ok && _cached_cards:
		return _cached_cards
	var to_return: Array[CardResource] = []
	var directory = DirAccess.open(card_folder)
	var files = directory.get_files()
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		var resource = load(card_folder + "/" + file)
		if !(resource is CardResource) || resource.test_card: continue
		to_return.append(resource)
	_cached_cards = to_return
	return to_return
