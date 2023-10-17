extends CardModifier

func _apply(health_component:HealthComponent,unit:Unit):
	var bound_callable = func(): return _on_day(health_component, unit)
	UniqueMetaId.store([health_component,self,"_on_day"], bound_callable)
	GameManager.I.on_day.connect(bound_callable)

func _un_apply(health_component:HealthComponent,_unit:Unit):
	var bound_callable = UniqueMetaId.retrieve([health_component,self,"_on_day"])
	GameManager.I.on_day.disconnect(bound_callable)

func _on_day(health_component:HealthComponent, unit:Unit):
	var heal_hit = Weapon.Hit.new()
	heal_hit.damage = -health_component.max_health * current_rank * params.percent_per_rank
	heal_hit.damage_type = Damage.Type.Heal
	heal_hit.hit = unit
	heal_hit.hit_creation_data = Weapon.HitCreationData.new(Vector3(unit.global_position.x,0.5,unit.global_position.z))
	
	unit.take_hit(heal_hit)
