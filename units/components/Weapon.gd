extends Node3D

class_name Weapon

const equal_battle_range:int = 5
const unequal_battle_damage_scale:float = 0.1

class HitCreationData:
	var hit_point: Vector3 = Vector3.ZERO
	var can_chain: bool = true
	var base_damage_scale: float = 1.0
	var base_pushback_scale: float = 1.0
	var can_crit: bool = true
	var apply_effects: Array[Effect] = []
	
	func _init(point:Vector3 = Vector3.ZERO):
		hit_point = point

class Hit:
	var direction:Vector2
	var crit_damage_multiplier: float
	var is_crit: bool
	var damage:float
	var pushback:float
	var hit_stun:float
	var flat_armor:int
	var crit_chance: float
	var damage_type: Damage.Type
	var hit_by
	var hit:Unit
	var apply_effects:Array[Effect] = []
	var hit_creation_data:HitCreationData
	
	var post_crit_damage: float:
		get:
			var armor = flat_armor if damage_type == Damage.Type.Basic else 0
			var dmg = (damage * crit_damage_multiplier) if is_crit else damage
			if dmg > 1:
				dmg = clampf(dmg - armor, 1, dmg)
				
				if Global.players_minus_enemies > equal_battle_range:
					if (hit.is_enemy):
						dmg *= (1.0 - unequal_battle_damage_scale)
					else:
						dmg *= (1.0 + unequal_battle_damage_scale)
				elif Global.players_minus_enemies < -equal_battle_range:
					if (hit.is_enemy):
						dmg *= (1.0 + unequal_battle_damage_scale)
					else:
						dmg *= (1.0 - unequal_battle_damage_scale)
			
			return round(dmg * 10.0)
	
	func duplicate():
		var obj = Hit.new()
		obj.direction = direction
		obj.crit_damage_multiplier = crit_damage_multiplier
		obj.is_crit = is_crit
		obj.damage = damage
		obj.pushback = pushback
		obj.hit_stun = hit_stun
		obj.crit_chance = crit_chance
		obj.damage_type = damage_type
		obj.hit_by = hit_by
		obj.hit = hit
		obj.hit_creation_data = hit_creation_data
		obj.flat_armor = flat_armor
		obj.apply_effects = apply_effects
		return obj

signal on_hit_landed(hit_data:Weapon.Hit)

@export var animation_tree: AnimationTreeExpressionExtension
@export var weapon_range: float = 3.0
@export var damage: float = 10.0
@export var damage_random_component: float = 2.0
@export var pushback: float = 5.0
@export var hit_stun: float = 0.5
@export var crit_chance: float = 0.01
@export var crit_damage_multiplier: float = 1.5
@export var damage_type: Damage.Type = Damage.Type.Basic
@export var animation_delay: float = 0
@export var disabled = false
@export var scales_with_day = false

var _current_pushback_scale: float = 1.0
var _current_damage_scale: float = 1.0

var unit:Unit
var create_hit = CallableStack.new(_create_hit)

func _ready():
	var root = get_tree().root
	var parent = get_parent()
	while parent != root:
		if parent is Unit:
			unit = parent
			break
		parent = parent.get_parent()

func _on_request_attack(_target:Unit, _me:Unit):
	pass #override me

func _set_pushback_scale(value: float):
	_current_pushback_scale = value

func _set_damage_scale(value: float):
	_current_damage_scale = value

func _on_enter_combat():
	Global.execute_later(func(): 
		animation_tree.set("parameters/conditions/in_combat", true)
		animation_tree.set("parameters/conditions/not_in_combat", false)
		, self, animation_delay)

func _on_exit_combat():
	Global.execute_later(func(): 
		animation_tree.set("parameters/conditions/in_combat", false)
		animation_tree.set("parameters/conditions/not_in_combat", true)
		, self, animation_delay)

func _try_to_attack(target:Unit, me:Unit) -> bool:
	#in range and ready to fire?
	if(disabled
	|| (target.global_position - me.global_position).length() > weapon_range
	|| (animation_tree.get("parameters/playback").get_current_node() != "idle_combat")) : return false
	
	#trigger animation
	animation_tree.activate_trigger("attack", animation_delay)
	
	return true

func _create_hit(enemy:Unit, hit_creation_data:HitCreationData = HitCreationData.new()) -> Weapon.Hit:
	
	var hit_data = Hit.new()
	hit_data.direction = Math.unit_v2(Math.v3_to_v2(enemy.global_position-global_position))
	hit_data.crit_chance = crit_chance if hit_creation_data.can_crit else 0.0
	hit_data.crit_damage_multiplier = crit_damage_multiplier
	hit_data.damage = (damage * hit_creation_data.base_damage_scale + randf_range(0, damage_random_component)) * _current_damage_scale
	if scales_with_day:
		hit_data.damage *= 1 + (GameManager.I._day / 100.0)
	hit_data.pushback = pushback * hit_creation_data.base_pushback_scale * _current_pushback_scale
	hit_data.hit_stun = hit_stun
	hit_data.damage_type = damage_type
	hit_data.hit_by = self
	hit_data.hit = enemy
	hit_data.hit_creation_data = hit_creation_data
	hit_data.apply_effects = hit_creation_data.apply_effects
	return hit_data
