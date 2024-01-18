extends Node3D

class_name TreasureChest

@export var treasure_models: Array[Node3D]
@export_category("Observables")
@export var ear_exchange_rate_resource: ObservableResource
@export_category("Signal Buses")
@export var on_treasure_chest_clicked_resource: SignalBus

@onready var treasure_height_component: HeightComponent = $"Model"

static var LOCATION: Vector3 = Vector3.ZERO
const ARC_HEIGHT: float = 4.0
const ARC_TIME: float = 1

var _base_scale: Vector3
var _scale_tweenifier: Tweenifier

func _ready():
	_base_scale = scale
	_scale_tweenifier = Tweenifier.new(self, "scale", 0.3, Tween.EaseType.EASE_OUT, Tween.TransitionType.TRANS_SPRING)
	treasure_height_component.after_first_height_set.connect(_set_location)
	call_deferred("_attach_to_on_money_changed")

func _set_location():
	LOCATION = treasure_height_component.global_position

func _attach_to_on_money_changed():
	MoneyManager.I.on_money_changed.connect(_on_money_changed)

func _exit_tree():
	MoneyManager.I.on_money_changed.disconnect(_on_money_changed)

func _on_money_changed(_type:MoneyManager.MoneyType, value:int, previous_value:int):
	if value > previous_value:
		scale = _base_scale * 1.15
		_scale_tweenifier.tween(_base_scale)
	
	var player_wealth = BuyOffersManager.get_player_resource_value(
		MoneyManager.I.get_resource(MoneyManager.MoneyType.Gold)
		, MoneyManager.I.get_resource(MoneyManager.MoneyType.Ear)
		, ear_exchange_rate_resource.value)
	
	for model in treasure_models:
		model.visible = false
	
	if player_wealth <= 500:
		treasure_models[0].visible = true
		treasure_models[0].position = Vector3.ZERO
	elif player_wealth <= 1500:
		treasure_models[1].visible = true
		treasure_models[1].position = Vector3.ZERO
	else:
		treasure_models[2].visible = true
		treasure_models[2].position = Vector3.ZERO

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		_on_click()

func _on_click():
	on_treasure_chest_clicked_resource.on_signal.emit()

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
