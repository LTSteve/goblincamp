extends Node

class_name GoblinCardManager

static var I: GoblinCardManager

@export var first_modifier_night: int = 5
@export var modifier_interval: int = 10

func _ready():
	I = self
