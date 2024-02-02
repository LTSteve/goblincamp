class_name Arc

const HALF: float = 0.5
const A: float = 2.828

var _arc_start: Vector3
var _arc_end: Vector3

var _arc_height: float = 1.0

func _init(arc_start:Vector3, arc_end:Vector3, arc_height:float):
	_arc_start = arc_start
	_arc_end = arc_end
	_arc_height = arc_height

func set_arc_end(arc_end:Vector3):
	_arc_end = arc_end

func get_arc_location(arc_progress:float):
	var ground_position = lerp(_arc_start, _arc_end, arc_progress)
	
	var x = (arc_progress - HALF) * A
	var height = -HALF * x * x + 1
	
	return ground_position + Vector3.UP * height * _arc_height
