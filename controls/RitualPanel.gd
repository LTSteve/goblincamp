extends TweenSlide

class_name RitualPanel

static var I: RitualPanel

@onready var container:Container = $"RitualPanel/MarginContainer/Offers/ScrollContainer/MarginContainer/VBoxContainer"
@onready var scroll_container: ScrollContainer = $"RitualPanel/MarginContainer/Offers/ScrollContainer"

@export var resource_textures: Array[Texture2D] = []

var _current_rituals: Array[Ritual] = []

func _ready():
	I = self
	super._ready()

func slide_in():
	if _current_rituals.is_empty():
		_on_day()
	scroll_container.scroll_vertical = 0
	super.slide_in()

func slide_out():
	CameraRig.I.unset_camera_angle_override()
	super.slide_out()

func _on_day():
	_create_rituals(GameManager.I.get_day())
	_create_ritual_display()

func _create_rituals(day: int):
	_current_rituals = []
	
	var ritual:Ritual
	
	#basic ritual gold and ears
	ritual = Ritual.new(Ritual.Type.Basic)
	ritual.prices = [day * 10 + 50, (day/2.0) as int + 1]
	ritual.resources = [MoneyManager.MoneyType.Gold, MoneyManager.MoneyType.Ear]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Gold], resource_textures[MoneyManager.MoneyType.Ear]]
	_current_rituals.append(ritual)
	
	#basic ritual hide and iron
	ritual = Ritual.new(Ritual.Type.Basic)
	ritual.prices = [(day/2.0) as int + 1 + randi_range(0,1), (day/2.0) as int + 1 + randi_range(0,1)]
	ritual.resources = [MoneyManager.MoneyType.Hide, MoneyManager.MoneyType.Iron]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Hide], resource_textures[MoneyManager.MoneyType.Iron]]
	_current_rituals.append(ritual)
	
	#basic ritual dust
	ritual = Ritual.new(Ritual.Type.Basic)
	ritual.prices = [day + 1 + randi_range(0,2)]
	ritual.resources = [MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Dust]]
	_current_rituals.append(ritual)
	
	#advanced ritual hide or iron and dust
	ritual = Ritual.new(Ritual.Type.Advanced)
	ritual.prices = [(day/2.0) as int + 1 + randi_range(0,1), (day/2.0) as int + 1 + randi_range(0,3)]
	ritual.resources = [MoneyManager.MoneyType.Hide if randf() > 0.5 else MoneyManager.MoneyType.Iron, MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[ritual.resources[0]], resource_textures[MoneyManager.MoneyType.Dust]]
	_current_rituals.append(ritual)
	
	#advanced ritual gold ears and dust 
	ritual = Ritual.new(Ritual.Type.Advanced)
	ritual.prices = [day * 10 + 50, day + 1 + randi_range(0, 10), day + 1 + randi_range(0, 10)]
	ritual.resources = [MoneyManager.MoneyType.Gold, MoneyManager.MoneyType.Ear, MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Gold], resource_textures[MoneyManager.MoneyType.Ear], resource_textures[MoneyManager.MoneyType.Dust]]
	_current_rituals.append(ritual)

func _create_ritual_display():
	var ritual_display_scene:PackedScene = DB.I.scenes.ritual_display_scene
	
	for child in container.get_children():
		child.queue_free()
	
	for ritual in _current_rituals:
		var new_ritual = ritual_display_scene.instantiate() as RitualDisplay
		new_ritual.ritual = ritual
		container.add_child(new_ritual)
		
		new_ritual.price_button.pressed.connect(_on_purchase_button_pressed.bind(ritual, new_ritual))

func _on_purchase_button_pressed(ritual:Ritual, ritual_display:RitualDisplay):
	if MoneyManager.I.try_spend_multiple(ritual.prices, ritual.resources):
		ritual_display.disable()
		PickProjectModel.I.open_ritual(ritual)

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		slide_out()
