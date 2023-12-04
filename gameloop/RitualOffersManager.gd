extends Node

class_name RitualOffersManager

static var I: RitualOffersManager

@export var resource_textures: Array[Texture2D] = []

@export_group("Observables")
@export var day_number_resource: ObservableResource
@export var ritual_offers_resource: ObservableResource

var one_free_epic: bool = true

func _ready():
	I = self
	day_number_resource.value_changed.connect(_day_number_changed)
	call_deferred("_day_number_changed", 0, 0)

func _day_number_changed(day_number,_old):
	_create_rituals(day_number)

func _create_rituals(day: int):
	var rituals = []
	
	var ritual:Ritual
	
	#basic ritual gold and ears
	ritual = Ritual.new(Ritual.Type.Epic if one_free_epic else Ritual.Type.Basic)
	ritual.prices = [day * 10 + 50, (day/2.0) as int + 1]
	ritual.resources = [MoneyManager.MoneyType.Gold, MoneyManager.MoneyType.Ear]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Gold], resource_textures[MoneyManager.MoneyType.Ear]]
	rituals.append(ritual)
	
	#basic broad ritual gold and hide or iron
	ritual = Ritual.new(Ritual.Type.Basic, Ritual.Size.Broad)
	ritual.prices = [day * 10 + 50, (day/4.0) as int + 1 + randi_range(0,1)]
	ritual.resources = [MoneyManager.MoneyType.Gold, MoneyManager.MoneyType.Hide if randf() > 0.5 else MoneyManager.MoneyType.Iron]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Gold], resource_textures[ritual.resources[1]]]
	rituals.append(ritual)
	
	#basic narrow ritual dust
	ritual = Ritual.new(Ritual.Type.Basic, Ritual.Size.Narrow)
	ritual.prices = [(day/2.0) as int + 1 + randi_range(0,2)]
	ritual.resources = [MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Dust]]
	rituals.append(ritual)
	
	#advanced ritual hide or iron and dust
	ritual = Ritual.new(Ritual.Type.Advanced)
	ritual.prices = [(day/3.0) as int + 1 + randi_range(0,1), (day/3.0) as int + 1 + randi_range(0,3)]
	ritual.resources = [MoneyManager.MoneyType.Hide if randf() > 0.5 else MoneyManager.MoneyType.Iron, MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[ritual.resources[0]], resource_textures[MoneyManager.MoneyType.Dust]]
	rituals.append(ritual)
	
	#advanced broad ritual gold ears and dust 
	ritual = Ritual.new(Ritual.Type.Advanced)
	ritual.prices = [day * 10 + 50, (day/2.0) as int + 1 + randi_range(0, 10), (day/2.0) as int + 1 + randi_range(0, 10)]
	ritual.resources = [MoneyManager.MoneyType.Gold, MoneyManager.MoneyType.Ear, MoneyManager.MoneyType.Dust]
	ritual.resource_textures = [resource_textures[MoneyManager.MoneyType.Gold], resource_textures[MoneyManager.MoneyType.Ear], resource_textures[MoneyManager.MoneyType.Dust]]
	rituals.append(ritual)
	
	ritual_offers_resource.value = rituals
