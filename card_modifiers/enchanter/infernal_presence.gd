extends CardModifier

var aoe_scene = preload("res://fx/generic_aoe.tscn")

func _apply(ranged_weapon:RangedWeapon,unit:Unit):
	var aoe = aoe_scene.instantiate() as AreaOfEffect
	aoe.enemies = true
	aoe.infinite = true
	aoe.interval = params.check_time
	aoe.radius = pow(current_rank, 1.5) * params.radius_per_rank
	aoe.callback = _on_hit_enemy.bind(ranged_weapon)
	unit.add_child(aoe)
	aoe.global_position = Vector3(unit.global_position.x,0.5,unit.global_position.z)
	UniqueMetaId.store([ranged_weapon, "aoe"], aoe)

func _un_apply(ranged_weapon:RangedWeapon,_unit:Unit):
	var aoe = UniqueMetaId.retrieve([ranged_weapon, "aoe"])
	aoe.queue_free()

func _on_hit_enemy(enemy:Unit, _aoe:AreaOfEffect, weapon):
	var effect = BurnEffect.new(enemy,
	weapon,
	params.damage)
	
	enemy.add_effect(effect)
