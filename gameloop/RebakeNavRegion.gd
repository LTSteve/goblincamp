extends NavigationRegion3D

class_name RebakeNavRegion

@export_group("Observables")
@export var buildings_resource: ObservableResource

@export_group("Inverse Signal Buses")
@export var todo_before_day_resource: InverseSignalBus

var _spawned_building: bool = false

func _ready():
	todo_before_day_resource.bind(_get_todo_before_day)
	buildings_resource.value_changed.connect(_buildings_changed)

func _buildings_changed(_v,_ov):
	_spawned_building = true

func _get_todo_before_day():
	return TodoListItem.new(_bake_nav_mesh)

func _bake_nav_mesh(todo_list):
	if _spawned_building:
		_spawned_building = false
		bake_navigation_mesh(true)
		todo_list.finish_step_after_signal(bake_finished)
	else:
		todo_list.mark_step_done()
