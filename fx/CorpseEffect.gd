extends Node3D

class_name CorpseEffect

const CORPSE_TIME : float = 15.0
const CORPSE_TIME_HALF : float = 7.0
const CORPSE_DISAPPEAR_TIME: float = 1.0

const FALL_OVER_TIME : float = 0.5
const FALL_OVER_VARIENCE: float = 0.1

@onready var timer: Timer = $"Timer"

var model_prefab: PackedScene
var death_location: Vector3
var death_rotation: Vector3
var death_scale: Vector3

var model: Node3D

func _ready():
	if !model_prefab: 
		queue_free()
		return
	
	# create corpse
	model = model_prefab.instantiate()
	add_child(model)
	self.global_position = death_location
	self.global_rotation = death_rotation
	self.global_scale(death_scale)
	
	# start despawn timer
	timer.wait_time = CORPSE_TIME_HALF if PrioritizedTaskManager.had_early_exit else CORPSE_TIME
	timer.start()
	
	# play 'fall over' animation
	Tweenifier.new(
		model, 
		"rotation_degrees", 
		FALL_OVER_TIME + randf_range(-FALL_OVER_VARIENCE, FALL_OVER_VARIENCE),
	).tween(
		Vector3(90,0,0).rotated(Vector3.UP, randf() * deg_to_rad(360))
	)
	Tweenifier.new(
		model, 
		"position", 
		FALL_OVER_TIME + randf_range(-FALL_OVER_VARIENCE, FALL_OVER_VARIENCE)
	).tween(
		model.position + Vector3(0,0.25,0)
	)

func _on_timer_end():
	# if we're struggling to keep up, just remove the corpse
	if PrioritizedTaskManager.had_early_exit:
		queue_free()
		return
	
	# play 'despawn' animation
	Tweenifier.new(
		model, 
		"position", 
		CORPSE_DISAPPEAR_TIME,
		Tween.EASE_IN
	).tween(
		model.position - Vector3(0,5,0)
	).done.connect(_then_queue_free)

func _then_queue_free():
	queue_free()
