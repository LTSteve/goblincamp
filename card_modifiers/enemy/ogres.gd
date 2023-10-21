extends CardModifier

func _initialize(_data):
	#must do basic application up front
	_apply(null,null)

func _apply(melee_weapon:MeleeWeapon,_unit):
	if !GameManager.unlocked_enemy_types.has(UnitSpawner.UnitType.Ogre):
		GameManager.unlocked_enemy_types.append(UnitSpawner.UnitType.Ogre)
		GameManager.force_spawn_enemy_type = UnitSpawner.UnitType.Ogre
	if current_rank == 2:
		#priority = after flat damage scaling
		melee_weapon.create_hit.add_override([melee_weapon, self, "_create_hit_override"],_create_hit_override, 50)

func _un_apply(melee_weapon:MeleeWeapon,_unit):
	GameManager.unlocked_enemy_types = GameManager.unlocked_enemy_types.filter(func(enemy_type): return enemy_type != UnitSpawner.UnitType.Ogre)
	melee_weapon.create_hit.remove_override([melee_weapon, self, "_create_hit_override"])

func _create_hit_override(_base_value:Weapon.Hit, current_value:Weapon.Hit):
	current_value.damage *= params.ogre_damage_boost
	current_value.pushback *= params.ogre_knockback_boost
	current_value.hit_stun *= params.ogre_stun_boost
	return current_value
