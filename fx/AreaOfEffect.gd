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
@export var hit_sfx: Array[AudioStream]

@export var clean_up_delay: float = 1

@export var players_resource: ObservableResource
@export var enemies_resource: ObservableResource

func _ready():
	if lifespan == 0:
		call_deferred("_effect_units")

func _process(delta):
	lifespan -= delta
	if !infinite && lifespan <= 0:
		delayed_queue_free()
		return
	
	delay -= delta
	if delay > 0: return
	
	_effect_units()
	
	times -= 1
	if infinite || times > 0:
		delay += interval
	else:
		delay += lifespan * 2

func delayed_queue_free():
	set_process(false)
	for particle in particles:
		particle.emitting = false
	Wait.timer(clean_up_delay, self, queue_free)

func _effect_units():
	for particle in particles:
		particle.emitting = true
	if hit_sfx && hit_sfx.size() > 0:
		var sfx = DB.I.scenes.leave_behind_sfx_scene.instantiate() as LeaveBehindSFX
		sfx.stream = hit_sfx.pick_random()
		get_tree().root.add_child(sfx)
	
	if !callback.is_valid(): return
	
	var units = Global.get_all_units_near_position((enemies_resource.value if enemies else ([] as Array[Unit])) + (players_resource.value if players else ([] as Array[Unit])), global_position, radius)
	for unit in units:
		callback.call(unit, self)
