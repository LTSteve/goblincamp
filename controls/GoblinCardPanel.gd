extends Panel

class_name GoblinCardPanel

var card_scene: PackedScene
@export var card_container: Container

@export_group("Observables")
@export var day_number_resource: Observable

@export_group("Inverse Signal Buses")
@export var todo_before_day_resource: InverseSignalBus

var _card_resource: CardResource

var _todo_list: TodoList

static var I: GoblinCardPanel

func _ready():
	card_scene = DB.I.scenes.card_display_scene
	I = self
	todo_before_day_resource.bind(_get_todo_before_day)

func _get_todo_before_day() -> TodoListItem:
	return TodoListItem.new(try_open)

func try_open(todo_list:TodoList):
	var day = day_number_resource.value + 1
	if day < GoblinCardManager.I.first_modifier_night || ((day - GoblinCardManager.I.first_modifier_night) % GoblinCardManager.I.modifier_interval) != 0: 
		todo_list.mark_step_done()
		return
	_card_resource = ModifierManager.get_next_enemy_card()
	
	var new_card = card_scene.instantiate() as CardDisplay
	new_card.card_resource = _card_resource
	new_card.show_next_rank = true
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
