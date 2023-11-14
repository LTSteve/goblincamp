extends Behaviour

class_name MerchantBehaviour

func initialize(brain:BrainComponent):
	var ctx = null
	brain.flee_range.input_event.connect(_merchant_input_event.bind(brain))
	brain.unit.visible = true
	call_deferred("_wire_up", brain.unit)
	return ctx

func _wire_up(unit):
	GameManager.I.on_day.connect(_on_day.bind(unit))
	GameManager.I.on_night.connect(_on_night.bind(unit))

func _on_day(unit):
	unit.visible = true

func _on_night(_day, unit):
	unit.visible = false

func process(_delta, _brain:BrainComponent, _ctx):
	return false

func _merchant_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int, brain: BrainComponent):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if GameManager.I.is_daytime:
			MerchantBehaviour.open_buy_panel(brain.unit)

static func open_buy_panel(merchant:Unit):
	BuyPanel.I.slide_in()
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = merchant
	CameraRig.I.set_camera_angle_override(camera_position)
