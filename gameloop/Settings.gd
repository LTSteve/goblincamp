class_name Settings

const cfg_file = "user://settings.cfg"
const settings_folder = "res://controls/settings_types"
const SETTINGS = "SETTINGS"

static var initialized = false
static var config: ConfigFile

static var settings_categories: Array[SettingsCategory] = []

class SettingsCategory:
	var settings: Array[SettingResource] = []
	var name: String
	func _init(n, s):
		name = n
		settings = s

static func _initialize():
	if initialized: return
	initialized = true
	
	#load setting resources (can't do this through DB right now since we need it on the main menu)
	var directory = DirAccess.open(settings_folder)
	var dirs = directory.get_directories()
	for dir in dirs:
		settings_categories.append(SettingsCategory.new(dir, _find_settings_in_folder(dir)))
	
	#find cfg file
	config = ConfigFile.new()
	if config.load(cfg_file) == ERR_FILE_CANT_OPEN:
		printerr("Can't load settings!")
	else:
		if config.has_section(SETTINGS):
			#load cfg file
			for category in settings_categories:
				for setting in category.settings:
					if config.has_section_key(SETTINGS + "_" + category.name, setting.name):
						setting.value = config.get_value(SETTINGS + "_" + category.name, setting.name)
					else:
						config.set_value(SETTINGS + "_" + category.name, setting.name, setting.default_setting)
						setting.value = setting.default_setting
		else:
			#make cfg file
			for category in settings_categories:
				for setting in category.settings:
					config.set_value(SETTINGS + "_" + category.name, setting.name, setting.default_setting)
					setting.value = setting.default_setting

static func _find_settings_in_folder(dir_name: String) -> Array[SettingResource]:
	var to_return: Array[SettingResource] = []
	
	var directory = DirAccess.open(settings_folder + "/" + dir_name)
	var files = directory.get_files()
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		var resource = load(settings_folder + "/" + dir_name + "/" + file)
		if !(resource is SettingResource): continue
		to_return.append(resource)
	
	return to_return

static func get_settings_categories() -> Array[SettingsCategory]:
	_initialize()
	return settings_categories

static func get_settings(name:String):
	_initialize()
	return Global.find_by_func(settings_categories, func(category): return category.name == name)

static func save_setting(setting:SettingResource):
	_initialize()
	var category = Global.find_by_func(settings_categories, func(category): return category.settings.has(setting))
	config.set_value(SETTINGS + "_" + category.name, setting.name, setting.value)
	config.save(cfg_file)

static func get_setting(category_name:String, setting_name:String):
	_initialize()
	var category = Global.find_by_func(settings_categories, func(category): return category.name == category_name)
	return Global.find_by_func(category.settings, func(val): return val.name == setting_name)
