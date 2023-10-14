extends Node

class_name HealthComponent

class HealthUpdate:
	var previous_health:float
	var current_health:float
	var max_health:float
	var health_percent:float
	var is_heal:bool

signal health_changed(health_update:HealthUpdate)
signal died

@export var max_health:float = 100.0

var _has_died = false

var current_health: float:
	get:
		return current_health
	set(value):
		var previous_health = current_health
		current_health = clampf(value, 0, max_health)
		
		var health_update = HealthUpdate.new()
		health_update.previous_health = previous_health
		health_update.current_health = current_health
		health_update.max_health = max_health
		health_update.health_percent = current_health_percent()
		health_update.is_heal = current_health >= previous_health
		
		health_changed.emit(health_update)
		if(current_health == 0 && !_has_died):
			_has_died = true
			died.emit()

func has_health_remaining() -> bool:
	return current_health > 0

func current_health_percent() -> float:
	return 0.0 if (max_health <= 0 || current_health <= 0) else (current_health / max_health)

func damage(hp:float):
	current_health -= hp

func heal(hp:float):
	damage(-hp)

func set_max_health(health:float):
	max_health = health

func _initialize_health():
	current_health = max_health

func _ready():
	call_deferred("_initialize_health")

func _on_recieved_hit(weapon_hit:Weapon.Hit):
	damage(weapon_hit.post_crit_damage)
