extends Weapon

class_name ChannelingWeapon

@export var channeled_effect_scene: PackedScene
@export var channeled_effect_spawn_point: Node3D

var _active_channeled_effect: Node

var create_channeled_scene = CallableStack.new(_create_channeled_scene)

func _on_begin_channeling():
	if channeled_effect_scene == null || _active_channeled_effect: return
	
	super._on_begin_channeling()
	
	#spawn channeling effect
	_active_channeled_effect = create_channeled_scene.execute()

func _create_channeled_scene():
	var effect = channeled_effect_scene.instantiate()
	get_tree().root.add_child(effect)
	return effect

func _on_tree_exiting():
	#clean up channeling effect
	if is_instance_valid(_active_channeled_effect): _active_channeled_effect.delayed_queue_free()

func _on_end_channeling():
	super._on_end_channeling()
	#clean up channeling effect
	if is_instance_valid(_active_channeled_effect): _active_channeled_effect.delayed_queue_free()
