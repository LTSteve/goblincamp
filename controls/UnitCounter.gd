extends HBoxContainer

class_name UnitCounter

@onready var player_unit_counter: Label = $"Label2"
@onready var enemy_unit_counter: Label = $"Label4"
@onready var day_counter: Label = $"Label6"

var _player_unit_count: int = 0
var _enemy_unit_count: int = 0

func _ready():
	call_deferred("_late_ready")

func _late_ready():
	GameManager.I.on_day.connect(_on_day)

func _on_day():
	day_counter.text = str(GameManager.I.get_day() + 1)

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
