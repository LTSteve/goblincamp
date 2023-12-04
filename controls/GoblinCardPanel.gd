extends UIPopup

class_name GoblinCardPanel

@onready var card_view:TextureRect3D = $"GoblinCardPanel/MarginContainer/3DTextureRect"

var card_scene: PackedScene
var _card_resource: CardResource

func open(todo_list:TodoList):
	card_scene = DB.I.scenes.card_display_scene
	_card_resource = ModifierManager.get_next_enemy_card()
	
	card_view.model_scene = DB.I.scenes.card_display_scene
	card_view.initialize()
	
	var card_display = card_view.model as CardDisplay
	card_display.card_resource = _card_resource
	card_display.no_flip = true
	card_display.initialize() 
	
	todo_list.mark_step_done()

func close(todo_list:TodoList):
	ModifierManager.apply_modifier(_card_resource)
	
	super.close(todo_list)

func on_close_clicked():
	popup_close.emit()
