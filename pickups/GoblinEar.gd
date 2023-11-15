extends Area3D

class_name GoblinEar

const SPAWN_TIME: float = 0.3
const ARC_TIME: float = 0.5
const ARC_HEIGHT: float = 2
const HALF: float = 0.5
const A: float = 2.828

@onready var model: Node3D = $"goblin_ear"
@onready var rotation_component: RotationComponent = $"RotationComponent"
@onready var landing_point: Node3D = $"GoblinEarLandingPoint"

@export var ears_resource: ObservableResource

var claimed: bool = false

var _arc_progress: float = 0.0

var _arc_start: Vector3

func _process(delta):
	var arc_end = landing_point.global_position
	if _arc_progress >= 1.0:
		model.global_position = arc_end
		rotation_component.turn_by_rot_dir(true, delta)
		rotation_component.apply_rotation(model)
		monitoring = true
		return
	
	var ground_position = lerp(_arc_start, arc_end, _arc_progress)
	var x = (_arc_progress - HALF) * A
	var height = -HALF * x * x + 1
	
	model.global_position = ground_position + Vector3.UP * height * ARC_HEIGHT

func _on_area_entered(area):
	if !(area is Unit): return
	
	MoneyManager.I.add_money(1, MoneyManager.MoneyType.Ear)
	ears_resource.value = ears_resource.value.filter(func(ear): return ear != self)
	queue_free()

func start_spawning(pos:Vector3):
	_arc_start = pos
	model.global_position = _arc_start
	model.visible = true
	model.scale = Vector3.ZERO
	
	var scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ONE, SPAWN_TIME)
	
	var arc_tween = create_tween()
	arc_tween.tween_property(self, "_arc_progress", 1.0, ARC_TIME)
	
	rotation_component.set_rotation(Math.random_rotation())
	rotation_component.apply_rotation(model)
	
	ears_resource.value += [self]
