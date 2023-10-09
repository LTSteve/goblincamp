@tool
class_name Point

var index: int
var point: Vector3
var color: Color
var normal: Vector3

func _init(i:int,p:Vector3,c:Color,n:Vector3):
	self.index = i
	self.point = p
	self.color = c
	self.normal = n
