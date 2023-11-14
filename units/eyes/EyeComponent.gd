extends Node3D

class_name EyeComponent

@onready var blink_animation_tree:AnimationTreeExpressionExtension = $"AnimationTree_Blink"

var _was_sleeping = false

func _on_recieved_hit(weapon_hit:Weapon.Hit):
	if !weapon_hit || weapon_hit.damage < 0: return
	blink_animation_tree.activate_trigger("pain")

func _on_state_changed(state_states: Array[Unit.State]):
	if !_was_sleeping && state_states.has(Unit.State.SLEEPING):
		blink_animation_tree.activate_trigger("sleep")
		_was_sleeping = true
	elif _was_sleeping && !state_states.has(Unit.State.SLEEPING):
		blink_animation_tree.activate_trigger("wake")
		_was_sleeping = false
