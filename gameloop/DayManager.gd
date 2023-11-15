extends Node

@export var navigation_region: NavigationRegion3D

@export_group("Observables")
@export var day_number_resource: ObservableResource
@export var is_day_resource: ObservableResource

@export var enemies_resource: ObservableResource
@export var buildings_resource: ObservableResource

var _spawned_building: bool = false

func _ready():
	enemies_resource.value_changed.connect(_on_enemies_changed)
	buildings_resource.value_changed.connect(_on_buildings_changed)

func _on_enemies_changed(enemies,_old_enemies):
	if enemies.size() == 0:
		cycle_to_day()

func _on_buildings_changed(_buildings, _old_buildings):
	_spawned_building = true

func cycle_to_day():
	is_day_resource.value = true

func cycle_to_night():
	TodoList.new([
	_bake_nav_mesh
	,GoblinCardPanel.try_open.bind(day_number_resource.value+1)
	], true).on_done(_start_next_day)

func _bake_nav_mesh(todo_list):
	if _spawned_building:
		navigation_region.bake_navigation_mesh(true)
		todo_list.finish_step_after_signal(navigation_region.bake_finished)
	else:
		todo_list.mark_step_done()

func _start_next_day():
	_spawned_building = false
	day_number_resource.value += 1
	is_day_resource.value = false
