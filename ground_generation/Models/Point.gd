@tool
class_name Point

var index: int
var point: Vector3
var color: Color
var normal: Vector3

func _init(index:int,point:Vector3,color:Color,normal:Vector3):
	self.index = index
	self.point = point
	self.color = color
	self.normal = normal
