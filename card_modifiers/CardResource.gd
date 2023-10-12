extends Resource

class_name CardResource

enum CardRarity {Normal,Rare,UltraRare}

@export var title: String
@export var descriptions: Array[String]
@export var rarity: CardRarity
@export var max_rank: int
@export var card_script: Script
@export var card_script_params: JSON
@export var apply_to: Array[String]
@export var group_filters: Array[String]
@export var include_enemies: bool
@export var include_players: bool
