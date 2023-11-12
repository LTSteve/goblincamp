extends Node

class_name HitBurstComponent

const BURST_THROTTLE: int = 100

var burst_scenes:Array[PackedScene] = []

var _last_burst: int = 0

func _ready():
	#{Basic, Heal, Fire, Bleed, Cold}
	burst_scenes = [
		DB.I.scenes.basic_burst_scene,
		DB.I.scenes.heal_burst_scene,
		DB.I.scenes.fire_burst_scene,
		DB.I.scenes.bleed_burst_scene,
		DB.I.scenes.cold_burst_scene
	]

func _on_recieved_hit(weapon_hit: Weapon.Hit):
	var current_time = Time.get_ticks_msec()
	if _last_burst > (current_time - BURST_THROTTLE): return
	
	var new_burst = burst_scenes[weapon_hit.damage_type].instantiate()
	get_tree().root.add_child(new_burst)
	new_burst.global_position = Vector3(weapon_hit.hit.global_position.x, weapon_hit.hit_creation_data.hit_point.y, weapon_hit.hit.global_position.z)
	(new_burst.find_child("GPUParticles3D") as GPUParticles3D).emitting = true
	
	_last_burst = current_time
