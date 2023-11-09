extends Node3D

class_name BountyComponent

@export var enabled: bool = false
@export var worth_base: int = 1
@export var worth_varience: int = 1

var _num_killed:int = 0

func _on_health_component_died():
	if !enabled: return
	var is_crit = randf() < (_num_killed * 0.15)
	
	var worth = worth_base
	if is_crit:
		worth += worth_varience
	
	var goblin_ear_scene = DB.I.scenes.goblin_ear_scene as PackedScene
	
	for _i in worth:
		var new_ear = goblin_ear_scene.instantiate() as GoblinEar
		get_tree().root.add_child(new_ear)
		var ear_spawn_point = Math.v3_to_v2(global_position) + Math.rand_v2_range(0.5, 2)
		new_ear.global_position = Math.v2_to_v3(ear_spawn_point)
		new_ear.start_spawning(global_position)

func _on_unit_on_get_kill(_value):
	_num_killed += 1
