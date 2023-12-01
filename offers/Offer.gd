class_name Offer

var model_scene_1: PackedScene
var model_scene_2: PackedScene

var unit_type_1: UnitSpawner.UnitType
var type_1_count: int

var unit_type_2: UnitSpawner.UnitType
var building_type_2: UnitSpawner.BuildingType
var type_2_is_building: bool = false
var type_2_count: int

var price: int

var name: String

const DESCRIPTIONS: Array[String] = [
	"",
	"Fuzzy",
	"Warm",
	"Amber",
	"Bulging",
	"Corned",
	"Damaged",
	"Frank",
	"Endless",
	"Goodly",
	"Hardcore",
	"Impared",
	"Jeweled",
	"Kingly",
	"Lonely",
	"Molting",
	"Nice",
	"Navigating",
	"Oppressive",
	"Pensive",
	"Quiet",
	"Rowdy",
	"Sulking",
	"Sultry",
	"Tame",
	"Tutting",
	"Unnerving",
	"Villanous",
	"Wounded",
	"Xtreme",
	"Yelling",
	"Yodeling",
	"Gregarious",
	"Zoomy"
]

const OBJECTS: Array[String] = [
	"Apples",
	"Bananas",
	"Cornbread-bits",
	"Dragons",
	"Eggplants",
	"Flowers",
	"Fowls",
	"Gargoyles",
	"Geese",
	"Humans",
	"Hydra",
	"Heffalumps",
	"Igloos",
	"Journeymen",
	"Killers",
	"Llamas",
	"Limes",
	"Mongrels",
	"Mages",
	"Neatnicks",
	"Ostriches",
	"People",
	"Petunias",
	"Quacks",
	"Rangers",
	"Rebels",
	"Sandwiches",
	"Towers",
	"Umbrellas",
	"Villains",
	"Wumbos",
	"Wombats",
	"Xylophones",
	"Yams",
	"Yaks",
	"Zoomers"
]

static func random_name():
	return "The %s %s" %[DESCRIPTIONS.pick_random(),OBJECTS.pick_random()]
