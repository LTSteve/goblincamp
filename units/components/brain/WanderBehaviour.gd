extends Behaviour

class_name WanderBehaviour

@export var wander_center: Vector3 = Vector3.ZERO
@export var min_wander_range: float = 10
@export var max_wander_range: float = 20

@export var min_wander_wait: float = 5
@export var max_wander_wait: float = 30

@export var day_number_resource: ObservableResource

const _almost_360_r: float = deg_to_rad(359.9)

class WanderData:
	var target:Vector3
	var time_to_next_wander:float
	var reached_destination:bool = true

func initialize(brain:BrainComponent):
	var wander_data = WanderData.new()
	wander_data.time_to_next_wander = randf_range(0.5,min_wander_wait)
	wander_data.target = brain.unit.global_position
	return wander_data

func assign_target(delta, _brain:BrainComponent, wander_data:WanderData):
	wander_data.time_to_next_wander -= delta
	if wander_data.time_to_next_wander <= 0:
		var wander_range = day_number_resource.value * 0.5 + 5
		wander_range = clampf(wander_range,min_wander_range, max_wander_range)
		wander_data.target = wander_center + Vector3.RIGHT.rotated(Vector3.UP, randf_range(0,_almost_360_r)) * randf_range(0, wander_range)
		wander_data.time_to_next_wander = randf_range(min_wander_wait, max_wander_wait)
		wander_data.reached_destination = false
	return wander_data

func process(_delta, brain:BrainComponent, wander_data:WanderData):
	if wander_data.reached_destination: return true
	brain.unit.set_movement_target(wander_data.target, 0.5)
	if brain.unit.global_position.distance_squared_to(wander_data.target) < 2:
		wander_data.reached_destination = true
	return true

