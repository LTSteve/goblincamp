extends DamageOverTimeEffect

class_name BurnEffect

const target_damage_per_tick: float = 5
const tick_time: float = 1.5

static var damage_scale_players: float = 1
static var damage_scale_enemies: float = 1

static var crit_chance_players: float = 0
static var crit_chance_enemies: float = 0

func _init(effected_unit:Unit, applier, damage: float):
	var crit_chance = 0
	
	if effected_unit.is_enemy:
		damage *= damage_scale_enemies
		crit_chance = crit_chance_enemies
	else:
		damage *= damage_scale_players
		crit_chance = crit_chance_players
	
	super(effected_unit, applier, damage, 1, damage * tick_time / target_damage_per_tick, tick_time, "burn", Damage.Type.Fire, Unit.State.BURNING, crit_chance)
