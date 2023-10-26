extends Node3D

class_name AreaOfEffect

@export var enemies: bool = false
@export var players: bool = false
@export var radius: float = 0
@export var delay: float = 0
@export var times: int = 1
@export var interval: float = 0.1
@export var lifespan: float = 2.0
@export var infinite: bool = false
var callback: Callable

@export var particles: Array[GPUParticles3D]
@export var leave_behind_sfx_scene: PackedScene = preload("res://sfx/leave_behind_sfx.tscn")
@export var hit_sfx: Array[AudioStream]

func _ready():
	if lifespan == 0:
		call_deferred("_effect_units")
	if hit_sfx && hit_sfx.size() > 0:
		var sfx = leave_behind_sfx_scene.instantiate() as LeaveBehindSFX
		sfx.stream = hit_sfx.pick_random()
		get_tree().root.add_child(sfx)

func _process(delta):
	lifespan -= delta
	if !infinite && lifespan <= 0:
		queue_free()
		return
	
	delay -= delta
	if delay > 0: return
	
	_effect_units()
	
	times -= 1
	if infinite || times > 0:
		delay += interval
	else:
		delay += lifespan * 2
	

func _effect_units():
	for particle in particles:
		particle.emitting = true
	var units = Global.get_all_units_near_position((Global.enemies if enemies else ([] as Array[Unit])) + (Global.players if players else ([] as Array[Unit])), global_position, radius)
	for unit in units:
		callback.call(unit, self)
