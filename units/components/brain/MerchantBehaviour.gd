extends Behaviour

class_name MerchantBehaviour

func initialize(brain:BrainComponent):
	var ctx = null
	brain.flee_range.input_event.connect(_merchant_input_event.bind(brain))
	return ctx

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
