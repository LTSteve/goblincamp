class_name Global

static var enemies: Array[Unit] = []
static var players: Array[Unit] = []
static var projectiles: Array[Projectile] = []

static func nearest_unit(units: Array[Unit], position):
	if(!units || units.size() == 0):
		return null
	
	var nearestUnit = units[0]
	var nearest_len_2 = (nearestUnit.global_position - position).length_squared()
	for unit in units:
		var len2 = (unit.global_position - position).length_squared()
		if(len2 < nearest_len_2):
			nearestUnit = unit
			nearest_len_2 = len2
	
	return nearestUnit

static func nearest_units(units:Array[Unit], position, max_count, max_dist2) -> Array[Unit]:
	if(!units || units.size() == 0):
		return []
	
	var nearest_us: Array[Unit] = []
	var nearest_len2s = []
	var furthest_nearest_len_2 = 0
	
	for unit in units:
		var len2 = (unit.global_position - position).length_squared()
		if len2 > max_dist2: continue
		
		#build the array in a sorted manner
		if nearest_us.size() < max_count:
			if len2 > furthest_nearest_len_2:
				furthest_nearest_len_2 = len2
				nearest_us.append(unit)
				nearest_len2s.append(len2)
			else:
				for i in nearest_us.size():
					var l2 = nearest_len2s[i]
					if l2 > len2:
						nearest_us.insert(i,unit)
						nearest_len2s.insert(i,l2)
						break
			continue
		
		if(len2 >= furthest_nearest_len_2): continue
		
		for i in nearest_us.size():
			var l2 = nearest_len2s[i]
			if l2 > len2:
				nearest_us.insert(i,unit)
				nearest_len2s.insert(i,l2)
				nearest_us.remove_at(max_count)
				nearest_len2s.remove_at(max_count)
				break
		
		furthest_nearest_len_2 = nearest_len2s[max_count - 1]
	
	return nearest_us

static func lowest_claims(units:Array[Unit]) -> Array[Unit]:
	if(!units || units.size() == 0):
		return []
	
	var lowest = 10000
	var lowest_units: Array[Unit] = []
	
	for unit in units:
		var claims = get_claims_on_unit(unit)
		if claims == lowest:
			lowest_units.append(unit)
		elif claims < lowest:
			lowest = claims
			lowest_units = [unit]
	
	return lowest_units

static func get_claims_on_unit(unit:Unit):
	var sum = 0
	for claim in unit.cardinal_claims:
		if claim:
			sum += 1
	return sum

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
