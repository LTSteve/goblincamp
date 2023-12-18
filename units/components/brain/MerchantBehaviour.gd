extends Behaviour

class_name MerchantBehaviour

static var _MERCHANT: Unit

@export_group("observables")
@export var is_day_resource: ObservableResource

func initialize(brain:BrainComponent):
	_MERCHANT = brain.unit
	brain.flee_range.input_event.connect(_merchant_input_event)
	
	brain.unit.visible = true
	brain.unit.set_process(true)
	is_day_resource.value_changed.connect(_on_day_changed.bind(brain.unit))
	
	return null

func _on_day_changed(is_day, _was_day, unit):
	unit.visible = is_day
	unit.set_process(is_day)

func process(_delta, _brain:BrainComponent, _ctx):
	return false

func _merchant_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if is_day_resource.value:
			MerchantBehaviour.open_buy_panel()

static func open_buy_panel():
	if ! _MERCHANT: return
	
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = _MERCHANT
	CameraRig.I.set_camera_angle_override(camera_position)
	
	var todo_before_merchant_resource := DB.I.observables.todo_before_merchant as InverseSignalBus
	var todo = todo_before_merchant_resource.inverse_signal()
	
	var _todo_list = TodoList.new(todo)
	_todo_list.on_done(func():
		var buy_panel = DB.I.scenes.buy_panel_scene.instantiate()
		HUD.I.on_popup_open(buy_panel)
		)
