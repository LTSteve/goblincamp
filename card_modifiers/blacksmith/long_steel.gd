extends CardModifier

var base_sword_length: float
var base_dagger_length: float

func _apply(node:Node3D,_unit):
	if node.is_in_group("Sword_Model"):
		if current_rank == 1: base_sword_length = node.scale.x
		_apply_to_model(node, base_sword_length)
	elif node.is_in_group("Dagger_Model"):
		if current_rank == 1: base_dagger_length = node.scale.x
		_apply_to_model(node, base_dagger_length)
	else:
		_apply_to_hitboxes(node)

func _un_apply(node:Node3D,_unit):
	if node.is_in_group("Sword_Model"):
		_un_apply_to_model(node, base_sword_length)
	elif node.is_in_group("Dagger_Model"):
		_un_apply_to_model(node, base_dagger_length)
	else:
		_un_apply_to_hitboxes(node)

func _apply_to_model(model:Node3D, base_length:float):
	model.scale.x = base_length + params.scale_per_rank * current_rank

func _un_apply_to_model(model:Node3D, base_length:float):
	model.scale.x = base_length

func _apply_to_hitboxes(hitboxes:Node3D):
	var scale = Vector3.ONE * (1.0 + params.scale_per_rank * current_rank)
	for hitbox in hitboxes.find_children("", "CollisionShape3D"):
		hitbox.scale = scale

func _un_apply_to_hitboxes(hitboxes:Node3D):
	for hitbox in hitboxes.find_children("", "CollisionShape3D"):
		hitbox.scale = Vector3.ONE
