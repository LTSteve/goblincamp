@tool
class_name Quad

var _tris: Array[Tri] = []

func _init(tri1:Tri, tri2:Tri):
	_tris.append(tri1)
	_tris.append(tri2)

func get_points():
	var points: Array[Point] = []
	
	for tri in _tris:
		points += tri.get_points()
	
	return points

func sample_height(x: float, y: float) -> float:
	if _tris[0].point_in_triangle(x,y):
		return _tris[0].sample_height(x,y)
	elif _tris[1].point_in_triangle(x,y):
		return _tris[1].sample_height(x,y)
	else:
		return 0
