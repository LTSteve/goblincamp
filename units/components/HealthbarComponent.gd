extends Node3D

@onready var sprite_3d: Sprite3D = $"Sprite3D"

@export var persist_duration: float = 1
@export var insist_persist_at: float = 0.4

var _size:float = 1
var _persist_cooldown = 0

func _on_health_component_health_changed(health_update:HealthComponent.HealthUpdate):
	_size = clampf(health_update.health_percent, 0, 1)
	_persist_cooldown = persist_duration

func _process(delta):
	_persist_cooldown -= delta
	sprite_3d.visible = _size < insist_persist_at || _persist_cooldown > 0
	scale = Vector3(_size, 1, 1)
