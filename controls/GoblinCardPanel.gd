extends Panel

class_name GoblinCardPanel

var card_scene: PackedScene
@export var card_container: Container

@export var first_modifier_night: int = 5
@export var modifier_interval: int = 10

var _card_resource: CardResource

var _todo_list: TodoList

static var I: GoblinCardPanel

func _ready():
	card_scene = DB.I.scenes.card_scene
	I = self

static func try_open(todo_list:TodoList, day: int):
	if !I || (day < I.first_modifier_night || ((day - I.first_modifier_night) % I.modifier_interval) != 0): 
		todo_list.mark_step_done()
		return
	I._card_resource = ModifierManager.get_next_enemy_card()
	
	var new_card = I.card_scene.instantiate() as CardDisplay
	new_card.card_resource = I._card_resource
	new_card.show_next_rank = true
	new_card.clickable = false
	I.card_container.add_child(new_card)
	
	I.visible = true
	I._todo_list = todo_list

func close():
	ModifierManager.apply_modifier(_card_resource)
	
	for child in card_container.get_children():
		child.queue_free()
	
	visible = false
	
	if _todo_list:
		_todo_list.mark_step_done()
		_todo_list = null

# for click-outs
func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		close()
