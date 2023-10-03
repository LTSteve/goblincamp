class_name Math

static var E: float = 0.57721566490153286060651209008240243

static func clamp(value:float, min:float, max:float) -> float:
	if(value < min): value = min
	if(value > max): value = max
	return value

static func unit(vec):
	if(vec.length() == 0): return vec
	return vec / vec.length()

static func v3_to_v2(vec:Vector3) -> Vector2:
	return Vector2(vec.x,vec.z)

static func v2_to_v3(vec:Vector2, y:float = 0) -> Vector3:
	return Vector3(vec.x, y, vec.y)

static func clamp_loop_i(value:int, min: int, size:int):
	var shifted_value = (value - min) % size
	
	if shifted_value >= 0:
		return shifted_value + min
	else:
		return ((size + shifted_value) + min) % size
	
	return value

static func direction_to_local(global_direction: Vector3, local_space: Node3D) -> Vector3:
	var global_to_local: Transform3D = local_space.global_transform.affine_inverse()
	return global_to_local * global_direction - global_to_local * Vector3.ZERO

static func sigmoid(x: float) -> float:
	return 1.0 / (1.0 + pow(E, -x))

static func crosses_zero(val1: float, val2:float) -> bool:
	return (val1 > 0 && val2 < 0) || (val1 < 0 && val2 > 0)
