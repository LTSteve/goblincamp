extends Behaviour

class_name WizardBehaviour

static var _I: WizardBehaviour
static var _WIZARD: Unit

@export var day_number_resource: ObservableResource
@export var is_day_resource: ObservableResource

func initialize(brain:BrainComponent):
	_I = self
	_WIZARD = brain.unit
	
	brain.unit.visible = false
	brain.unit.set_process(false)
	DB.I.observables.is_day.value_changed.connect(_on_day_changed.bind(brain.unit))
	
	brain.flee_range.input_event.connect(_wizard_input_event)
	
	return null

func _wizard_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if is_day_resource.value && WizardBehaviour.is_wizard_active():
			WizardBehaviour.open_buy_panel()

func _on_day_changed(is_day, _was_day, unit):
	unit.visible = WizardBehaviour.is_wizard_active() if is_day else false
	unit.set_process(unit.visible)

static func open_buy_panel():
	if ! _WIZARD: return
	
	var ritual_panel = DB.I.scenes.ritual_panel_scene.instantiate() as RitualPanel
	HUD.I.on_popup_open(ritual_panel)
	
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = _WIZARD
	CameraRig.I.set_camera_angle_override(camera_position)

static func is_wizard_active():
	if !_I: return false
	var day = _I.day_number_resource.value
	return (day > 2) && ((day % 3) == 0)
