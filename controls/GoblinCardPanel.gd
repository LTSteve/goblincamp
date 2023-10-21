extends Panel

class_name GoblinCardPanel

@export var card_scene: PackedScene
@export var card_container: Container

@export var first_modifier_night: int = 1
@export var modifier_interval: int = 5

var _card_resource: CardResource

var _todo_list: TodoList

static var I: GoblinCardPanel

func _ready():
	I = self

func try_open(todo_list:TodoList, day: int):
	if day < first_modifier_night || ((day - first_modifier_night) % modifier_interval) != 0:
		todo_list.mark_step_done()
		return
	_card_resource = ModifierManager.get_next_enemy_card()
	
	var new_card = card_scene.instantiate() as CardDisplay
	new_card.card_resource = _card_resource
	new_card.show_next_rank = true
	new_card.clickable = false
	card_container.add_child(new_card)
	
	visible = true
	_todo_list = todo_list
	

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
