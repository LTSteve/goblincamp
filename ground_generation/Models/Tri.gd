@tool
class_name Tri

var _points: Array[Point] = []

var _k: float
var _normal: Vector3

func _init(point_a: Vector3,point_b: Vector3,point_c: Vector3,index: int, color:Color):
	var ab : Vector3 = point_b - point_a
	var bc : Vector3 = point_c - point_b
	var ca : Vector3 = point_a - point_c
	var cross_ab_bc : Vector3 = -ab.cross(bc)
	var cross_bc_ca : Vector3 = -bc.cross(ca)
	var cross_ca_ab : Vector3 = -ca.cross(ab)
	_normal = Math.unit_v3(cross_ab_bc + cross_bc_ca + cross_ca_ab)
	_k =  -(_normal.x * point_a.x + _normal.y * point_a.y + _normal.z * point_a.z)
	
	_points.append(Point.new(index, point_a, color, _normal))
	_points.append(Point.new(index+1, point_b, color, _normal))
	_points.append(Point.new(index+2, point_c, color, _normal))

func get_points():
	return _points

func sample_height(x: float, z: float) -> float:
	return _height_on_plane(x,z)

func point_in_triangle(x: float, z: float):
	return _point_in_triangle(Vector2(x,z), Math.v3_to_v2(_points[0].point), Math.v3_to_v2(_points[1].point), Math.v3_to_v2(_points[2].point))

func _height_on_plane(x:float, z:float):
	return (_normal.x * x + _normal.z * z + _k)/-_normal.y

func _point_in_triangle(point: Vector2, point_1: Vector2, point_2: Vector2, point_3: Vector2):
	var d1 = _sign(point, point_1, point_2)
	var d2 = _sign(point, point_2, point_3)
	var d3 = _sign(point, point_3, point_1)
	
	var has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0)
	var has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0)
	
	return !(has_neg && has_pos)

func _sign(p_1:Vector2,p_2:Vector2,p_3:Vector2) -> float:
	return (p_1.x - p_3.x) * (p_2.y - p_3.y) - (p_2.x - p_3.x) * (p_1.y - p_3.y)
