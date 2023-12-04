extends UIPopup

class_name RitualPanel

@onready var container:Container = $"RitualPanel/MarginContainer/Offers/ScrollContainer/MarginContainer/VBoxContainer"
@onready var scroll_container: ScrollContainer = $"RitualPanel/MarginContainer/Offers/ScrollContainer"

@export_group("Observables")
@export var ritual_offers_resource: ObservableResource

func open(todo_list:TodoList):
	_create_ritual_display()
	scroll_container.scroll_vertical = 0
	super.open(todo_list)

func close(todo_list:TodoList):
	CameraRig.I.unset_camera_angle_override()
	super.close(todo_list)

func _create_ritual_display():
	var ritual_display_scene:PackedScene = DB.I.scenes.ritual_display_scene
	
	for child in container.get_children():
		child.queue_free()
	
	for ritual in ritual_offers_resource.get_value():
		var new_ritual = ritual_display_scene.instantiate() as RitualDisplay
		new_ritual.ritual = ritual
		container.add_child(new_ritual)
		
		new_ritual.price_button.pressed.connect(_on_purchase_button_pressed.bind(ritual, new_ritual))

func _on_purchase_button_pressed(ritual:Ritual, ritual_display:RitualDisplay):
	if MoneyManager.I.try_spend_multiple(ritual.prices, ritual.resources):
		ritual_display.disable()
		ritual.available = false
		
		var pick_project_modal: PickProjectModel = DB.I.scenes.pick_project_scene.instantiate()
		pick_project_modal.generate_ritual_cards(ritual)
		HUD.I.on_popup_open(pick_project_modal)
		
		if ritual.type == Ritual.Type.Epic:
			RitualOffersManager.I.one_free_epic = false
