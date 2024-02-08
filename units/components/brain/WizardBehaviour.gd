extends Behaviour

class_name WizardBehaviour

static var _I: WizardBehaviour
static var _WIZARD: Unit

@export var day_number_resource: ObservableResource
@export var is_day_resource: ObservableResource

class WizardBehaviourContext:
	var poofParticles: GPUParticles3D

func initialize(brain:BrainComponent):
	_I = self
	_WIZARD = brain.unit
	
	call_deferred("_set_unit_model_invisible", brain.unit)
	brain.unit.set_process(false)
	
	var ctx = WizardBehaviourContext.new()
	ctx.poofParticles = brain.unit.find_child("PoofParticles")
	
	DB.I.observables.is_day.value_changed.connect(_on_day_changed.bind(brain.unit, ctx))
	
	brain.flee_range.input_event.connect(_wizard_input_event)
	
	return ctx

func _set_unit_model_invisible(unit:Unit):
	unit.model.visible = false

func _wizard_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if is_day_resource.value && WizardBehaviour.is_wizard_active():
			WizardBehaviour.open_buy_panel()

func _on_day_changed(is_day, _was_day, unit, ctx: WizardBehaviourContext):
	if WizardBehaviour.is_wizard_active():
		ctx.poofParticles.restart()
	
	unit.model.visible = WizardBehaviour.is_wizard_active() if is_day else false
	unit.set_process(unit.model.visible)

static func open_buy_panel():
	if ! _WIZARD: return
	
	var ritual_panel = DB.I.scenes.ritual_panel_scene.instantiate() as RitualPanel
	HUD.I.on_popup_open(ritual_panel)
	
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = _WIZARD
	CameraRig.I.set_camera_angle_override(camera_position)

static func is_wizard_active_day():
	if !_I: return false
	var day = _I.day_number_resource.value
	return (day > 2) && ((day % 3) == 0)

static func is_wizard_active_night():
	if !_I: return false
	var day = _I.day_number_resource.value - 1
	return (day > 2) && ((day % 3) == 0)

static func is_wizard_active():
	if !_I: return false
	var is_day = _I.is_day_resource.value
	return is_wizard_active_day() if is_day else is_wizard_active_night()
