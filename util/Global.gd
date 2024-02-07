class_name Global

static var players_minus_enemies: int

static func claim_nearest_unclaimed_ear(position, ears):
	if(!ears || ears.size() == 0):
		return null
	
	var nearest = null
	var nearest_len_2 = INF
	for ear in ears:
		if !is_instance_valid(ear) || ear.claimed: continue
		var len2 = (ear.global_position - position).length_squared()
		if(len2 < nearest_len_2):
			nearest = ear
			nearest_len_2 = len2
	
	if nearest: nearest.claimed = true
	return nearest

static var _building_closest_to_center: Building = null

static func get_building_closest_to_center(buildings: Array) -> Building:
	if is_instance_valid(_building_closest_to_center): 
		return _building_closest_to_center
		
	var position = Vector3.ZERO
	var nearest:Building = null
	var nearest_len_2 = INF
	for building in buildings:
		if !is_instance_valid(building): continue
		var len2 = (building.global_position - position).length_squared()
		if(len2 < nearest_len_2):
			nearest = building
			nearest_len_2 = len2
	
	_building_closest_to_center = nearest
	return _building_closest_to_center

static func nearest_unit(units: Array, position):
	if(!units || units.size() == 0):
		return null
	
	var nearest = null
	var nearest_len_2 = INF
	for unit in units:
		if !is_instance_valid(unit): continue
		var len2 = (unit.global_position - position).length_squared()
		if(len2 < nearest_len_2):
			nearest = unit
			nearest_len_2 = len2
	
	return nearest

static func furthest_unit(units: Array, position):
	if(!units || units.size() == 0):
		return null
	
	var furthest = null
	var furthest_len_2 = -1
	for unit in units:
		if !is_instance_valid(unit): continue
		var len2 = (unit.global_position - position).length_squared()
		if(len2 > furthest_len_2):
			furthest = unit
			furthest_len_2 = len2
	
	return furthest


static func nearest_units(units:Array, position, max_count, max_dist2) -> Array:
	if(!units || units.size() == 0):
		return []
	
	var nearest_us: Array = []
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

static func lowest_claims(units:Array, already_claimed: Unit = null) -> Array:
	if(!units || units.size() == 0):
		return []
	
	if ! is_instance_valid(already_claimed):
		already_claimed = null
	
	var lowest = 10000
	var lowest_units: Array = []
	
	for unit in units:
		var claims = get_claims_on_unit(unit)
		if unit == already_claimed:
			claims -= 1
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

static func get_all_units_near_position(units: Array, position:Vector3, radius: float) -> Array:
	if(!units || units.size() == 0):
		return []
	
	var r2 = radius * radius
	
	var all: Array = []
	for unit in units:
		if((unit.global_position - position).length_squared() <= r2):
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

static func find_by_func(arr,fn:Callable):
	for i in arr.size():
		var value = arr[i]
		if fn.call(value): return value
	return null
