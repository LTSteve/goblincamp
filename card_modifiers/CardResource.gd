extends Resource

class_name CardResource

enum CardRarity {Normal,Rare,UltraRare}

@export var building_card: bool
@export var test_card: bool
@export var title: String
## can format with available data
## ex: Increase ALL damage by {([current_rank]+1)*[.damage_increase_percent]}
## {} = expression (will be evaluated)
## [x] = property of current modifier
## [.x] = property of current modifier json data
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
@export var unlocked: bool = false
