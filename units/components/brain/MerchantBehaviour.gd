extends Behaviour

class_name MerchantBehaviour

static var _MERCHANT: Unit
static var _MERCHANT_BRAIN: BrainComponent

static var _OVERRIDE_LOOK: bool = false

@export_group("observables")
@export var is_day_resource: ObservableResource
@export var buildings_resource: ObservableResource

class MerchantBehaviourContext:
	var isFleeing: bool
	var targetFleeLocation: Vector3
	var comfortable_dist2: float = 4.0

func initialize(brain:BrainComponent):
	_MERCHANT = brain.unit
	_MERCHANT_BRAIN = brain
	brain.flee_range.input_event.connect(_merchant_input_event)
	
	brain.unit.visible = true
	brain.unit.set_process(true)
	
	brain.weapons = _bind_to_all_weapons(brain,typeof(ChannelingWeapon))
	
	var ctx := MerchantBehaviourContext.new()
	
	is_day_resource.value_changed.connect(_on_day_changed.bind(brain.unit, ctx))
	
	return ctx

func _on_day_changed(is_day, _was_day, unit, ctx: MerchantBehaviourContext):
	if is_day:
		ctx.isFleeing = false
		unit.visible = true
		unit.set_process(true)
		return
	
	var nearest_building = Global.get_building_closest_to_center(buildings_resource.value)
	if nearest_building == null:
		unit.visible = false
		unit.set_process(false)
		return
	
	ctx.targetFleeLocation = nearest_building.global_position
	ctx.isFleeing = true

func process(_delta, brain:BrainComponent, ctx: MerchantBehaviourContext):
	if _OVERRIDE_LOOK:
		var merch_to_cam := CameraRig.I.camera.global_position - brain.unit.global_position
		brain.unit.override_facing_direction(Math.v3_to_v2(merch_to_cam))
		return true
	
	if !ctx.isFleeing: return false
	
	if ctx.targetFleeLocation == brain.unit.global_position:
		return true
	
	if brain.unit.global_position.distance_squared_to(ctx.targetFleeLocation) <= ctx.comfortable_dist2:
		ctx.targetFleeLocation = brain.unit.global_position
		brain.unit.visible = false
		brain.unit.set_process(false)
	else:
		brain.unit.set_movement_target(ctx.targetFleeLocation)
	return true

func _merchant_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int):
	if !(event is InputEventMouseButton): return
	if (event as InputEventMouseButton).pressed:
		if is_day_resource.value:
			MerchantBehaviour.open_buy_panel()

static func open_buy_panel():
	if ! _MERCHANT: return
	
	var brain := _MERCHANT_BRAIN
	
	var camera_position = CameraRig.CameraSettings.new()
	camera_position.locked_to = _MERCHANT
	camera_position.locked_to_offset = CameraRig.I.calculate_vendor_offset()
	CameraRig.I.set_camera_angle_override(camera_position)
	
	#activate 'in combat' mode
	brain.enter_combat.emit()
	
	# turn towards camera, then start 'channeling'
	_OVERRIDE_LOOK = true
	brain.unit.set_movement_target(brain.unit.global_position)
	brain.begin_channeling.emit()
	var merch_to_cam := CameraRig.I.camera.global_position - brain.unit.global_position
	brain.unit.override_facing_direction(Math.v3_to_v2(merch_to_cam))
	
	var todo_before_merchant_resource := DB.I.observables.todo_before_merchant as InverseSignalBus
	var todo = todo_before_merchant_resource.inverse_signal()
	
	var _todo_list = TodoList.new(todo)
	_todo_list.on_done(func():
		var buy_panel = DB.I.scenes.buy_panel_scene.instantiate()
		HUD.I.on_popup_open(buy_panel)
		
		buy_panel.popup_close.connect(func():
			# on buy panel close, stop channeling and exit 'in combat' mode
			brain.end_channeling.emit()
			brain.exit_combat.emit()
			MerchantBehaviour._OVERRIDE_LOOK = false
			brain.unit.clear_override_facing_direction()
			)
		)
