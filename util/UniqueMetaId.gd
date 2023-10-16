class_name UniqueMetaId

static var dictionary:Dictionary = {}

static func create(context:Array):
	var id:String = ""
	for obj in context:
		id += obj if obj is String else str(obj.get_instance_id())
	return id

static func store(context:Array, data):
	var id = create(context)
	dictionary[id] = data

#destructively retrieve, clean up after yoself
static func retrieve(context:Array):
	var id = create(context)
	if dictionary.has(id):
		var value = dictionary[id]
		dictionary.erase(value)
		return value
	return null

static func has(context:Array) -> bool:
	var id = create(context)
	return dictionary.has(id)
