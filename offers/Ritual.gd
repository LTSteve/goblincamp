class_name Ritual

enum Type {Basic, Advanced}

var prices: Array[int] = []
var resources: Array[MoneyManager.MoneyType] = []
var resource_textures: Array[Texture2D] = []

var type: Type

func _init(t:Type):
	type = t
