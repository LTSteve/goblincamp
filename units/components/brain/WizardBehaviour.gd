extends Behaviour

class_name WizardBehaviour

static var _I: WizardBehaviour

func initialize(brain:BrainComponent):
	_I = self
	brain.unit.visible = false
	call_deferred("_wire_up", brain.unit)
	var ctx = null
	brain.flee_range.input_event.connect(_wizard_input_event.bind(brain))
	return ctx

func _wire_up(unit):
	GameManager.I.on_day.connect(_on_day.bind(unit))
	GameManager.I.on_night.connect(_on_night.bind(unit))

func process(_delta, _brain:BrainComponent, _ctx):
	return false

func _wizard_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int, brain: BrainComponent):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if GameManager.I.is_daytime && WizardBehaviour.is_wizard_active():
			WizardBehaviour.open_buy_panel(brain.unit)

func _on_day(unit):
	unit.visible = WizardBehaviour.is_wizard_active()

func _on_night(_day, unit):
	unit.visible = false

static func open_buy_panel(wizard:Unit):
	RitualPanel.I.slide_in()
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = wizard
	CameraRig.I.set_camera_angle_override(camera_position)

static func is_wizard_active():
	var day = GameManager.I.get_day()
	return (day > 2) && ((day % 3) == 0)
