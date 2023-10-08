@tool

extends MeshInstance3D

class_name GroundMesh

@export var normal: Vector3

var _planet_data:PlanetData
var quads:Array[Quad] = []
var noise_array:Array[float] = []
var axis_a:Vector3
var axis_b:Vector3
var max_possible_slope:float

func regenerate_mesh(planet_data: PlanetData):
	_planet_data = planet_data
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertex_array: PackedVector3Array = PackedVector3Array()
	var uv_array: PackedVector2Array = PackedVector2Array()
	var normal_array: PackedVector3Array = PackedVector3Array()
	var index_array: PackedInt32Array = PackedInt32Array()
	var color_array: PackedColorArray = PackedColorArray()
	
	var resolution: int = planet_data.resolution
	var num_verticies: int = resolution * resolution
	var num_indices: int = (resolution-1) * (resolution-1) * 6
	max_possible_slope = planet_data.max_height * planet_data.color_scale / (1.0/(resolution-1) as float)
	
	noise_array = []
	quads = []
	
	for i in num_verticies:
		noise_array.append(randf())
	
	vertex_array.resize(num_indices)
	uv_array.resize(num_indices)
	normal_array.resize(num_indices)
	index_array.resize(num_indices)
	color_array. resize(num_indices)
	
	axis_a = Vector3(normal.y, normal.z, normal.x)
	axis_b = normal.cross(axis_a)
	
	for y in range(resolution-1):
		for x in range(resolution-1):
			var tri_index = (x + y * (resolution - 1)) * 6
			
			var top_left:Vector3 = _point_on_unit_cube(x, y)
			var top_right:Vector3 = _point_on_unit_cube(x + 1, y)
			var bottom_left:Vector3 = _point_on_unit_cube(x, y+1)
			var bottom_right:Vector3 = _point_on_unit_cube(x+1, y+1)
			
			var tri1
			var tri2
			
			if randf() > 0.5:
				tri1 = Tri.new(bottom_left, bottom_right, top_left, tri_index, _get_color_from_slope(bottom_left,bottom_right,top_left,planet_data.colors))
				tri2 = Tri.new(bottom_right, top_right, top_left, tri_index+3, _get_color_from_slope(bottom_right,bottom_right,top_left,planet_data.colors))
			else:
				tri1 = Tri.new(bottom_left, top_right, top_left, tri_index, _get_color_from_slope(bottom_left,top_right,top_left,planet_data.colors))
				tri2 = Tri.new(bottom_right, top_right, bottom_left, tri_index+3, _get_color_from_slope(bottom_right,top_right,bottom_left,planet_data.colors))
			
			var quad = Quad.new(tri1,tri2)
			quads.append(quad)
			var quad_points: Array[Point] = quad.get_points()
			for point in quad_points:
				index_array[point.index] = point.index
				vertex_array[point.index] = point.point
				color_array[point.index] = point.color
				normal_array[point.index] = point.normal
	
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	arrays[Mesh.ARRAY_COLOR] = color_array
	
	call_deferred("_update_mesh", arrays)

func sample_height(x:float, z:float) -> float:
	var scaled_x:float = (x - global_position.x) / scale.x 
	var scaled_z:float = (z - global_position.z) / scale.z
	var percent = _location_to_percent(Vector2(scaled_x,scaled_z))
	var index = _percent_to_index(percent)
	if index.x < 0 || index.x >= (_planet_data.resolution - 1) || index.y < 0 || index.y >= (_planet_data.resolution - 1):
		return 0
	var i = _index(index.x, (_planet_data.resolution - 2)-index.y, _planet_data.resolution - 1)
	if i < 0 || i >= quads.size():
		print("real oob", index, " in ", _planet_data.resolution, " of ", i)
		return 0
	var quad = quads[i]
	var height = quad.sample_height(scaled_x,scaled_z) * scale.y
	return height

func _index(x: int, y:int, resolution:int) -> int:
	return x + y * resolution

func _point_on_unit_cube(x:int, y:int) -> Vector3:
	var height_r = noise_array[x + y * _planet_data.resolution]
	var height = normal * height_r * _planet_data.max_height
	var percent: Vector2 = _index_to_percent(x, y)
	return height + _percent_to_location(percent)

func _index_to_percent(x:int, y:int) -> Vector2:
	return Vector2(x,y) / (_planet_data.resolution - 1)

func _percent_to_index(percent:Vector2) -> Vector2i:
	return percent * (_planet_data.resolution - 1)

func _percent_to_location(percent:Vector2) -> Vector3:
	return (percent.x - 0.5) * 2.0 * axis_a + (percent.y - 0.5) * 2 * axis_b

func _location_to_percent(location:Vector2) -> Vector2:
	#currently just assuming ground mesh is on the ground, didn't feel like math
	return Vector2((location.x / 2.0) + 0.5, (location.y/2.0) + 0.5)

func _get_color_from_slope(point_a:Vector3, point_b:Vector3, point_c:Vector3, colors:Array[Color]):
	#assumes +y is up
	var ab_slope = absf((point_b.y - point_a.y) / Vector2(point_b.x, point_b.z).distance_to(Vector2(point_a.x, point_a.z)))
	var bc_slope = absf((point_c.y - point_b.y) / Vector2(point_c.x, point_c.z).distance_to(Vector2(point_b.x, point_b.z)))
	var ca_slope = absf((point_a.y - point_c.y) / Vector2(point_a.x, point_a.z).distance_to(Vector2(point_c.x, point_c.z)))
	
	var avg_slope = (ab_slope + bc_slope + ca_slope) / 3.0
	
	return _get_color_from_percent(avg_slope / max_possible_slope, colors)

func _get_color_from_percent(percent:float, colors:Array[Color]):
	var index = clampi((percent * colors.size()) as int, 0, colors.size()-1)
	return colors[index]

func _update_mesh(arrays: Array):
	var _mesh : ArrayMesh = ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
