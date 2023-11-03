extends Node

class_name HitBurstComponent

const BURST_THROTTLE: float = 0.1

var burst_scenes:Array[PackedScene] = []

var _initialized: bool = false

var _burst_throttle: float = 0

func _process(delta):
	_burst_throttle -= delta
	if _initialized: return
	if !DB.I.scenes || !DB.I.scenes.has("basic_burst_scene"): return
	
	#{Basic, Heal, Fire, Bleed, Cold}
	burst_scenes = [
		DB.I.scenes.basic_burst_scene,
		DB.I.scenes.heal_burst_scene,
		DB.I.scenes.fire_burst_scene,
		DB.I.scenes.bleed_burst_scene,
		DB.I.scenes.cold_burst_scene
	]
	_initialized = true

func _on_recieved_hit(weapon_hit: Weapon.Hit):
	if !_initialized || _burst_throttle > 0: return
	
	var new_burst = burst_scenes[weapon_hit.damage_type].instantiate()
	get_tree().root.add_child(new_burst)
	new_burst.global_position = Vector3(weapon_hit.hit.global_position.x, weapon_hit.hit_creation_data.hit_point.y, weapon_hit.hit.global_position.z)
	(new_burst.find_child("GPUParticles3D") as GPUParticles3D).emitting = true
	
	_burst_throttle = BURST_THROTTLE
