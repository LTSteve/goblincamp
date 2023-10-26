extends Behaviour

class_name RepulseBehaviour

@export var push_force:float = 1

func initialize(brain:BrainComponent):
	return brain.unit.find_child("VelocityComponent")

func process(delta, brain:BrainComponent, velocity_component:VelocityComponent):
	var sum = Vector2.ZERO
	for ally in brain.nearby_allies:
		if !is_instance_valid(ally): continue
		var separation = Math.v3_to_v2(brain.unit.global_position - ally.global_position)
		if separation == Vector2.ZERO: separation = Math.rand_v2()
		var dist2 = separation.length_squared()
		var dir = separation / dist2
		var force = (brain.flee_dist2 - dist2) / brain.flee_dist2
		sum += force * force * push_force * dir
	for enemy in brain.fleeing:
		if !is_instance_valid(enemy): continue
		var separation = Math.v3_to_v2(brain.unit.global_position - enemy.global_position)
		if separation == Vector2.ZERO: separation = Math.rand_v2()
		var dist2 = separation.length_squared()
		var dir = separation / dist2
		var force = (brain.flee_dist2 - dist2) / brain.flee_dist2
		sum += force * force * force * push_force * dir
	velocity_component.add_velocity(sum * delta)
	
	return false
