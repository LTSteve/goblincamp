class_name Ritual

enum Type {Basic, Advanced, Epic}
enum Size {Broad, Normal, Narrow}

var prices: Array[int] = []
var resources: Array[MoneyManager.MoneyType] = []
var resource_textures: Array[Texture2D] = []

var type: Type
var size: Size

func _init(t:Type, s:Size = Size.Normal):
	type = t
	size = s
