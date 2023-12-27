extends Node

@export_group("Signal Buses")
@export var on_treasure_chest_clicked_resource: SignalBus

func _ready():
	on_treasure_chest_clicked_resource.on_signal.connect(_open_treasure_screen)

func _open_treasure_screen():
	var treasure_chest_panel := DB.I.scenes.treasure_chest_panel_scene.instantiate() as TreasureChestPanel
	HUD.I.on_popup_open(treasure_chest_panel)
