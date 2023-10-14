extends Resource

class_name CardResource

enum CardRarity {Normal,Rare,UltraRare}

@export var test_card: bool
@export var title: String
@export var descriptions: Array[String]
@export var rarity: CardRarity
@export var max_rank: int
@export var card_script: Script
@export var card_script_params: JSON
## the node types to apply to
@export var apply_to: Array[String]
## the group/s to filter application by
@export var group_filters: Array[String]
@export var include_enemies: bool
@export var include_players: bool
@export var icon_texture: Texture2D
