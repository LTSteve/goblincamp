class_name UniqueMetaId

static var dictionary = {}

static func create(context:Array):
	var id:String = ""
	for obj in context:
		id += obj if obj is String else str(obj.get_instance_id())
	return id

static func store(context:Array, data):
	var id = create(context)
	dictionary[id] = data

static func retrieve(context:Array):
	var id = create(context)
	return dictionary[id]

static func has(context:Array) -> bool:
	var id = create(context)
	return dictionary.has(id)
