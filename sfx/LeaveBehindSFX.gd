extends AudioStreamPlayer3D

class_name LeaveBehindSFX

@export var lifespan = 2.0
@export var _setting: SettingResource

func _ready():
	volume_db = linear_to_db(_setting.value)
	play()

func _process(delta):
	lifespan -= delta
	if lifespan <= 0:
		queue_free()
