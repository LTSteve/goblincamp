extends Button

class_name OpenDisenchantButton

static var I: OpenDisenchantButton

func _ready():
	I = self

func enable():
	GameManager.I.on_day.connect(_on_day)
	GameManager.I.on_night.connect(_on_night)
	#visible = true #have to wait until the on_day tick to get any de power anyway

func _on_day():
	visible = true

func _on_night(_day):
	visible = false
