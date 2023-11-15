extends HBoxContainer

class_name UnitCounter

@onready var player_unit_counter: Label = $"Label2"
@onready var enemy_unit_counter: Label = $"Label4"
@onready var day_counter: Label = $"Label6"

var _player_unit_count: int = 0
var _enemy_unit_count: int = 0

func _ready():
	DB.I.observables.day_number.value_changed.connect(_day_changed)

func _day_changed(day_number, _last_day):
	day_counter.text = str(day_number + 1)

func _on_spawn_unit(unit:Unit):
	if !is_instance_valid(unit) || unit.is_npc: return
	
	if unit.is_enemy:
		_enemy_unit_count += 1
		enemy_unit_counter.text = str(_enemy_unit_count)
		(unit.find_child("HealthComponent") as HealthComponent).died.connect(func(): 
			_enemy_unit_count -= 1
			enemy_unit_counter.text = str(_enemy_unit_count))
	else:
		_player_unit_count += 1
		player_unit_counter.text = str(_player_unit_count)
		(unit.find_child("HealthComponent") as HealthComponent).died.connect(func(): 
			_player_unit_count -= 1
			player_unit_counter.text = str(_player_unit_count))
