class_name UniqueMetaId

static func create(context:Array):
	var id:String = ""
	for obj in context:
		id += obj if obj is String else str(obj.get_instance_id())
	return id
