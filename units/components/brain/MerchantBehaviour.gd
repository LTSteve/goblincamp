extends Behaviour

class_name MerchantBehaviour

static var _MERCHANT: Unit

@export_group("observables")
@export var is_day_resource: ObservableResource
@export var buildings_resource: ObservableResource

class MerchantBehaviourContext:
	var isFleeing: bool
	var targetFleeLocation: Vector3
	var comfortable_dist2: float = 4.0

func initialize(brain:BrainComponent):
	_MERCHANT = brain.unit
	brain.flee_range.input_event.connect(_merchant_input_event)
	
	brain.unit.visible = true
	brain.unit.set_process(true)
	
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

func assign_target(_delta, _brain:BrainComponent, _behaviour_data):
	pass

func process(_delta, brain:BrainComponent, ctx: MerchantBehaviourContext):
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
