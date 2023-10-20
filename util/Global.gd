class_name Global

static var enemies: Array[Unit] = []
static var players: Array[Unit] = []
static var projectiles: Array[Projectile] = []

static func nearest_unit(units: Array[Unit], position):
	if(!units || units.size() == 0):
		return null
	
	var nearestUnit = units[0]
	for unit in units:
		if((unit.global_position - position).length()
		< (nearestUnit.global_position - position).length()):
			nearestUnit = unit
	
	return nearestUnit

static func get_all_units_near_position(units: Array[Unit], position:Vector3, radius: float) -> Array[Unit]:
	if(!units || units.size() == 0):
		return []
	
	var all: Array[Unit] = []
	for unit in units:
		if((unit.global_position - position).length() <= radius):
			all.append(unit)
	
	return all

static func valid_instance_or_null(node:Node):
	if is_instance_valid(node):
		return node
	return null

static func execute_later(fn:Callable, node_ctx:Node, delay: float):
	if delay == 0:
		fn.call()
	else:
		var timer = Timer.new()
		timer.connect("timeout", fn)
		timer.connect("timeout", timer.queue_free)
		timer.set_wait_time(delay)
		node_ctx.add_child(timer)
		timer.start()
