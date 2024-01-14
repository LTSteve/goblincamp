extends Area3D

class_name GoblinEar

const SPAWN_TIME: float = 0.3
const ARC_TIME: float = 0.5
const ARC_HEIGHT: float = 2

@onready var model: Node3D = $"goblin_ear"
@onready var rotation_component: RotationComponent = $"RotationComponent"
@onready var landing_point: Node3D = $"GoblinEarLandingPoint"

@export var ears_resource: ObservableResource

var claimed: bool = false

var _arc_progress: float = 0.0

var _spawn_arc: Arc
var _collect_arc: Arc

func _process(delta):
	rotation_component.turn_by_rot_dir(true, delta)
	rotation_component.apply_rotation(model)
	
	if _collect_arc:
		_process_collect_arc(delta)
		return
	_process_spawn_arc(delta)

func _process_collect_arc(_delta):
	if _arc_progress >= 1.0:
		model.global_position = _collect_arc.get_arc_location(1.0)
		
		MoneyManager.I.add_money(1, MoneyManager.MoneyType.Ear)
		ears_resource.value = ears_resource.value.filter(func(ear): return ear != self)
		queue_free()
		return
	
	model.global_position = _collect_arc.get_arc_location(_arc_progress)

func _process_spawn_arc(_delta):
	_spawn_arc.set_arc_end(landing_point.global_position)
	
	if _arc_progress >= 1.0:
		model.global_position = _spawn_arc.get_arc_location(1.0)
		monitoring = true
		return
	
	model.global_position = _spawn_arc.get_arc_location(_arc_progress)

func _on_area_entered(area):
	if !(area is Unit): return
	
	_arc_progress = 0.0
	_collect_arc = Arc.new(model.global_position, TreasureChest.LOCATION, TreasureChest.ARC_HEIGHT)
	var arc_tween = create_tween()
	arc_tween.tween_property(self, "_arc_progress", 1.0, TreasureChest.ARC_TIME)
	
	set_process(true)

func start_spawning(pos:Vector3):
	_spawn_arc = Arc.new(pos, landing_point.global_position, ARC_HEIGHT)
	
	model.global_position = pos
	model.visible = true
	model.scale = Vector3.ZERO
	
	var scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ONE, SPAWN_TIME)
	
	var arc_tween = create_tween()
	arc_tween.tween_property(self, "_arc_progress", 1.0, ARC_TIME)
	
	rotation_component.set_rotation(Math.random_rotation())
	rotation_component.apply_rotation(model)
	
	ears_resource.value += [self]
