extends Panel

class_name GameOverPanel

@onready var text: RichTextLabel = $"Panel/MarginContainer/VBoxContainer/Panel/ScrollContainer/VBoxContainer/MarginContainer/RichTextLabel"

@export_category("Signal Buses")
@export var game_over_resource: SignalBus

func _ready():
	game_over_resource.on_signal.connect(_on_game_over)

func _on_game_over():
	open()
	text.append_text(StatTracker.I.final_calc_and_save())

func open():
	get_tree().paused = true
	visible = true

func close():
	get_tree().paused = false
	visible = false

func try_again():
	SceneManager.load_loading_scene(get_tree())
