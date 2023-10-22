class_name Math

static var E: float = 0.57721566490153286060651209008240243
static var almost_360_rad: float = deg_to_rad(359.99)
static var rad_90: float = deg_to_rad(90)
static var rad_45: float = deg_to_rad(45)

enum Cardinal { RIGHT, UP_RIGHT, UP, UP_LEFT, LEFT, DOWN_LEFT, DOWN, DOWN_RIGHT }

static var Cardinal_As_Direction = [Vector2.RIGHT, Vector2(0.5,-0.5), Vector2.UP, Vector2(-0.5, -0.5), Vector2.LEFT, Vector2(-0.5, 0.5), Vector2.DOWN, Vector2(0.5, 0.5)]

#returns the cardinals in order of closeness
static func nearest_cardinals(from:Vector2, to:Vector2):
	var dir = from - to
	var sorted_cardinals = []
	for cardinal in Cardinal_As_Direction.size():
		var card_dir = Cardinal_As_Direction[cardinal]
		var card_dir_d2 = card_dir.distance_squared_to(dir)
		var inserted = false
		for sorted_cardinal_index in sorted_cardinals.size():
			var sorted_card_dir = Cardinal_As_Direction[sorted_cardinals[sorted_cardinal_index]]
			if sorted_card_dir.distance_squared_to(card_dir) > card_dir_d2:
				sorted_cardinals.insert(sorted_cardinal_index, cardinal as Cardinal)
				inserted = true
		if !inserted:
			sorted_cardinals.append(cardinal as Cardinal)
	return sorted_cardinals

static func unit_v2(vec:Vector2):
	if(vec == Vector2.ZERO): return vec
	return vec / vec.length()

static func unit_v3(vec:Vector3):
	if(vec == Vector3.ZERO): return vec
	return vec / vec.length()

static func v3_to_v2(vec:Vector3) -> Vector2:
	return Vector2(vec.x,vec.z)

static func v2_to_v3(vec:Vector2, y:float = 0) -> Vector3:
	return Vector3(vec.x, y, vec.y)

static func clamp_loop_i(value:int, min_v: int, size:int):
	var shifted_value = (value - min_v) % size
	
	if shifted_value >= 0:
		return shifted_value + min_v
	else:
		return ((size + shifted_value) + min_v) % size

static func direction_to_local(global_direction: Vector3, local_space: Node3D) -> Vector3:
	var global_to_local: Transform3D = local_space.global_transform.affine_inverse()
	return global_to_local * global_direction - global_to_local * Vector3.ZERO

static func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + pow(E, -x))

static func crosses_zero(val1: float, val2:float) -> bool:
	return (val1 > 0 && val2 < 0) || (val1 < 0 && val2 > 0)

static func random_rotation() -> float:
	return deg_to_rad(randf()*359.99)

static func rangef(start:float, end:float, step:float, limit:int = 200) -> Array[float]:
	if step <= 0 || start >= end: return [start]
	var r = end - start
	var numbers:Array[float] = []
	for i in min(ceil(r/step), limit):
		numbers.append(i * step + start)
	return numbers

static func rand_v2():
	var angle = randf_range(0,almost_360_rad)
	return Vector2.RIGHT.rotated(angle)

static func rand_v2_range(min_dist:float, max_dist: float):
	var v2 = rand_v2()
	return v2 * randf_range(min_dist,max_dist)
