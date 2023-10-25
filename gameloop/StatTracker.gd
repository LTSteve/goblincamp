extends Node

class_name StatTracker

static var I: StatTracker

const cfg_file = "user://high_scores.cfg"


var _user_friendly_text_day = {
	money_gained = "Money Gained",
	money_spent = "Money Spent",
	
	blacksmiths_purchased = "Blacksmiths Purchased",
	leatherworkers_purchased = "Leatherworkers Purchased",
	enchaters_purchased = "Enchaters Purchased",
	
	knights_purchased = "Knights Purchased",
	witches_purchased = "Witches Purchased",
	woodsman_purchased = "Woodsman Purchased",
	knights_lost = "Knights Lost",
	witches_lost = "Witches Lost",
	woodsman_lost = "Woodsman Lost",
	
	goblins_killed = "Goblins Killed",
	imps_killed = "Imps Killed",
	ogres_killed = "Ogres Killed",
	
	normal_damage_delt = "Normal Damage Delt",
	fire_damage_delt = "Fire Damage Delt",
	bleed_damage_delt = "Bleed Damage Delt",
	healing = "Healing Recieved",
	
	normal_damage_recieved = "Normal Damage Recieved",
	fire_damage_recieved = "Fire Damage Recieved",
	bleed_damage_recieved = "Bleed Damage Recieved",
	enemy_healing = "Enemy Healing Recieved",
	
	wave_length_ms = "Wave Length (s)"
}

var _day_template = {
	money_gained = 0,
	money_spent = 0,
	
	blacksmiths_purchased = 0,
	leatherworkers_purchased = 0,
	enchaters_purchased = 0,
	
	knights_purchased = 0,
	witches_purchased = 0,
	woodsman_purchased = 0,
	knights_lost = 0,
	witches_lost = 0,
	woodsman_lost = 0,
	
	goblins_killed = 0,
	imps_killed = 0,
	ogres_killed = 0,
	
	normal_damage_delt = 0,
	fire_damage_delt = 0,
	bleed_damage_delt = 0,
	healing = 0,
	
	normal_damage_recieved = 0,
	fire_damage_recieved = 0,
	bleed_damage_recieved = 0,
	enemy_healing = 0,
	
	wave_length_ms = 0
}

var _user_friendly_text_stats = {
	largest_army = "Largest Army",
	largest_enemy_army = "Largest Enemy Army",
	total_run_time_ms = "Total Run Time (s)",
	nights = "Nights"
}

var _stats = {
	largest_army = 0,
	largest_enemy_army = 0,
	total_run_time_ms = 0,
	nights = []
}

var _run_start_time: int
var _day_start_time: int

var _current_army_size: int = 0
var _current_enemy_army_size: int = 0

var _current_day

func _ready():
	I = self
	_run_start_time = Time.get_ticks_msec()
	_on_day()

func final_calc_and_save():
	_current_day.wave_length_ms = Time.get_ticks_msec() - _day_start_time
	_stats.nights.append(_current_day)
	_stats.total_run_time_ms = Time.get_ticks_msec() - _run_start_time
	
	_stats.total_run_time_ms = _stats.total_run_time_ms / 1000.0
	
	#find cfg file
	var old_config = ConfigFile.new()
	var config = ConfigFile.new()
	if old_config.load(cfg_file) == ERR_FILE_CANT_OPEN:
		printerr("Can't load scores!")
	else:
		for stat in _stats.keys():
			if stat != "nights":
				config.set_value("OVERALL", _user_friendly_text_stats[stat], _stats[stat])
		
		config.set_value("OVERALL", "Nights Survived", _stats.nights.size() - 1)
		
		var day_sum = _day_template.duplicate()
		
		for night in _stats.nights:
			for prop in night.keys():
				day_sum[prop] += night[prop]
		
		day_sum.wave_length_ms = day_sum.wave_length_ms / 1000.0
		
		for prop in day_sum.keys():
			config.set_value("TOTALS", _user_friendly_text_day[prop], day_sum[prop])
		
		var to_return = config.encode_to_text()
		
		config.save(cfg_file)
		return to_return

func _on_day():
	if _current_day:
		_current_day.wave_length_ms = Time.get_ticks_msec() - _day_start_time
		_stats.nights.append(_current_day)
	_day_start_time = Time.get_ticks_msec()
	_current_day = _day_template.duplicate()

func _on_units_child_entered_tree(node):
	if !(node is Unit): return
	var group = node.get_groups()[0]
	match group:
		"Knight":
			_current_day.knights_purchased += 1
		"Witch":
			_current_day.witches_purchased += 1
		"Woodsman":
			_current_day.woodsman_purchased += 1
	
	node.find_child("HealthComponent").died.connect(_on_unit_died.bind(node))
	node.on_recieved_hit.connect(_on_unit_recieved_hit.bind(node))
	
	if node.is_enemy:
		_current_enemy_army_size += 1
		if _current_enemy_army_size > _stats.largest_enemy_army:
			_stats.largest_enemy_army = _current_enemy_army_size
	else:
		_current_army_size += 1
		if _current_army_size > _stats.largest_army:
			_stats.largest_army = _current_army_size

func _on_unit_died(unit:Unit):
	var group = unit.get_groups()[0]
	match group:
		"Knight":
			_current_day.knights_lost += 1
			_current_army_size -= 1
		"Witch":
			_current_day.witches_lost += 1
			_current_army_size -= 1
		"Woodsman":
			_current_day.woodsman_lost += 1
			_current_army_size -= 1
		"Goblin":
			_current_day.goblins_killed += 1
			_current_enemy_army_size -= 1
		"Imp":
			_current_day.imps_killed += 1
			_current_enemy_army_size -= 1
		"Ogre":
			_current_day.ogres_killed += 1
			_current_enemy_army_size -= 1

func _on_unit_recieved_hit(weapon_hit:Weapon.Hit, unit:Unit):
	match weapon_hit.damage_type:
		Damage.Type.Basic:
			if unit.is_enemy:
				_current_day.normal_damage_delt += weapon_hit.post_crit_damage
			else:
				_current_day.normal_damage_recieved += weapon_hit.post_crit_damage
		Damage.Type.Bleed:
			if unit.is_enemy:
				_current_day.bleed_damage_delt += weapon_hit.post_crit_damage
			else:
				_current_day.bleed_damage_recieved += weapon_hit.post_crit_damage
		Damage.Type.Fire:
			if unit.is_enemy:
				_current_day.fire_damage_delt += weapon_hit.post_crit_damage
			else:
				_current_day.fire_damage_recieved += weapon_hit.post_crit_damage
		
		Damage.Type.Heal:
			if unit.is_enemy:
				_current_day.enemy_healing -= weapon_hit.post_crit_damage
			else:
				_current_day.healing -= weapon_hit.post_crit_damage

func _on_obsticles_child_entered_tree(node):
	if !(node is Building): return
	
	match (node as Building).building_type:
		UnitSpawner.BuildingType.Blacksmith:
			_current_day.blacksmiths_purchased += 1
		UnitSpawner.BuildingType.Leatherworker:
			_current_day.leatherworkers_purchased += 1
		UnitSpawner.BuildingType.Enchanter:
			_current_day.enchanters_purchased += 1
	

func _on_money_manager_on_change(new_value:int, old_value:int):
	var change = new_value - old_value
	if change > 0:
		_current_day.money_gained += change
	if change < 0:
		_current_day.money_spent -= change
