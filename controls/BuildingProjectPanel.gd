extends UIPopup

class_name BuildingProjectPanel

@onready var title:Label = $"BuildingProjectPanel/MarginContainer3/Label"
@onready var card_view:TextureRect3D = $"BuildingProjectPanel/MarginContainer/3DTextureRect"

var card_display_scene: PackedScene

var _selected_card: CardResource
var _cards: Array[CardResource]
var _building: Building

func _ready():
	card_display_scene = DB.I.scenes.card_display_scene

func set_data(card:CardResource, building:Building):
	_selected_card = card
	_cards = building.all_cards
	_building = building

func open(todo_list: TodoList):
	title.text = _building.get_groups()[0].to_upper()
	
	_set_up_card_view()
	
	super.open(todo_list)

func _set_up_card_view():
	card_view.model_scene = DB.I.scenes.card_display_scene
	card_view.initialize()
	
	var card_display = card_view.model as CardDisplay
	card_display.card_resource = _selected_card
	card_display.initialize() 

func change_project():
	var pick_project_modal: PickProjectModel = DB.I.scenes.pick_project_scene.instantiate()
	pick_project_modal.generate_building_cards(_building.building_type)
	pick_project_modal.on_building_card_selected.connect(_building.new_project_selected)
	HUD.I.on_popup_open(pick_project_modal)
