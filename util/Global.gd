class_name Global

static var enemies: Array[Unit] = []
static var players: Array[Unit] = []

static func nearest_unit(units: Array[Unit], position):
	if(!units || units.size() == 0):
		return null
	
	var nearestUnit = units[0]
	for unit in units:
		if((unit.global_position - position).length()
		< (nearestUnit.global_position - position).length()):
			nearestUnit = unit
	
	return nearestUnit
