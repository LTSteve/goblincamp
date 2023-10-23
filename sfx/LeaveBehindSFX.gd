extends AudioStreamPlayer3D

class_name LeaveBehindSFX

@export var lifespan = 2.0

func _ready():
	play()

func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
