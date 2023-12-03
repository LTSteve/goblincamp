extends Node

class_name GameOverManager

@export_group("Observables")
@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

@export_category("Signal Buses")
@export var game_over_resource: SignalBus

func _ready():
	players_resource.value_changed.connect(_on_players_changed)

func _on_players_changed(players,_old_players):
	if players.size() == 0:
		game_over()

func game_over():
	Wait.timer(2, self, func():
		if players_resource.value.size() == 0 && enemies_resource.value.size() != 0:
			game_over_resource.on_signal.emit()
			var game_over_panel = DB.I.scenes.game_over_panel_scene.instantiate() as GameOverPanel
			HUD.I.on_popup_open(game_over_panel)
	)
