extends Node3D

class_name PathfinderComponent

@onready var navigation_agent = $"../NavigationAgent3D"

@export var at_location_distance: float = 1.5

var _get_next_path_position_task: PrioritizedTaskManager.PrioritizedTask

var _at_location_dist_2: float

var _movement_target = Vector3.ZERO
var _next_path_location = Vector3.ZERO
var _nav_finished = true

func _ready():
	_at_location_dist_2 = at_location_distance * at_location_distance
	navigation_agent.path_desired_distance = at_location_distance
	navigation_agent.target_desired_distance = at_location_distance

func find_new_path(movement_target:Vector3):
	navigation_agent.set_target_position(movement_target)
	_movement_target = movement_target
	_next_path_location = navigation_agent.get_next_path_position()
	_nav_finished = false

func get_next_direction(stunned:bool):
	if stunned: return Vector2.ZERO
	_nav_finished = _nav_finished || _movement_target.distance_squared_to(global_position) < _at_location_dist_2
	if _nav_finished: return Vector2.ZERO
	
	if _next_path_location.distance_squared_to(global_position) < _at_location_dist_2:
		if !_get_next_path_position_task || _get_next_path_position_task.done:
			_get_next_path_position_task = PrioritizedTaskManager.add_medium_priority_task(func(): 
				_next_path_location = navigation_agent.get_next_path_position()
				, self)
		return Vector2.ZERO
	
	var current_agent_position: Vector2 = Math.v3_to_v2(global_position)
	var next_path_position: Vector2 = Math.v3_to_v2(_next_path_location)
	
	return Math.unit_v2(next_path_position - current_agent_position)
