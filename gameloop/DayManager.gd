extends Node

@export_group("Observables")
@export var day_number_resource: ObservableResource
@export var is_day_resource: ObservableResource

@export var enemies_resource: ObservableResource

@export_category("Signal Buses")
@export var next_day_button_pressed_resource: SignalBus

@export_group("Inverse Signal Buses")
@export var todo_before_day_resource: InverseSignalBus

var _spawned_building: bool = false

func _ready():
	enemies_resource.value_changed.connect(_on_enemies_changed)
	next_day_button_pressed_resource.on_signal.connect(cycle_to_night)

func _on_enemies_changed(enemies,_old_enemies):
	if enemies.size() == 0:
		cycle_to_day()

func _on_buildings_changed(_buildings, _old_buildings):
	_spawned_building = true

func cycle_to_day():
	is_day_resource.value = true

func cycle_to_night():
	var todo = todo_before_day_resource.inverse_signal(TYPE_CALLABLE)
	TodoList.new(todo, true).on_done(_start_next_day)

func _start_next_day():
	_spawned_building = false
	day_number_resource.value += 1
	is_day_resource.value = false
