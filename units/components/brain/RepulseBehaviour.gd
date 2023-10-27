extends Behaviour

class_name RepulseBehaviour

@export var push_force:float = 1
@export var flee_dist: float = 8
@export var repulse_dist: float = 3

class RepulseContext:
	var velocity_component:VelocityComponent
	
	func _init(vc):
		velocity_component = vc

func initialize(brain:BrainComponent):
	return RepulseContext.new(brain.unit.find_child("VelocityComponent"))

func process(delta, brain:BrainComponent, ctx:RepulseContext):
	var sum = Vector2.ZERO
	
	for ally in brain.nearby_allies:
		if !is_instance_valid(ally): continue
		sum += _get_force(brain, ally.global_position)
	
	for enemy in brain.fleeing:
		if !is_instance_valid(enemy): continue
		sum += _get_force(brain, enemy.global_position)
	
	ctx.velocity_component.add_velocity(sum * delta)
	return false

func _get_force(brain:BrainComponent, pos:Vector3):
	var separation = Math.v3_to_v2(brain.unit.global_position - pos)
	if separation == Vector2.ZERO: separation = Math.rand_v2()
	var dist = separation.length()
	var dir = separation / dist
	var force = ((flee_dist - dist) / flee_dist) if dist < repulse_dist else 0
	return force * force * push_force * dir
