class_name Effect

var buff: bool
var duration: float = 1
var unit: Unit
var id: String = ""

func update_duration_and_return_is_finished(delta) -> bool:
	if !is_instance_valid(unit):
		print("Effect being called on invalid unit!")
		return true
	
	duration -= delta
	
	var is_finished = duration <= 0
	
	if is_finished: unit.remove_effect(self)
	
	return is_finished

func update(delta):
	update_duration_and_return_is_finished(delta)

func on_apply():
	pass

func on_remove():
	pass

func try_replace_existing(effects_list: Array[Effect]) -> bool:
	for effect in effects_list:
		if effect.id == id:
			effect.replace_with(self)
			return true
	
	return false

func replace_with(effect:Effect):
	duration = effect.duration