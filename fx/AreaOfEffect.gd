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

func _process(delta):
	lifespan -= delta
	
	delay -= delta
	if delay > 0: return
	
	for particle in particles:
		particle.emitting = true
	var units = Global.get_all_units_near_position((Global.enemies if enemies else ([] as Array[Unit])) + (Global.players if players else ([] as Array[Unit])), global_position, radius)
	for unit in units:
		callback.call(unit, self)
	
	if !infinite && lifespan <= 0:
		queue_free()
		return
	
	times -= 1
	if infinite || times > 0:
		delay += interval
	else:
		delay += lifespan * 2
	
