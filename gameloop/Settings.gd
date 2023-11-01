class_name Settings

const cfg_file = "user://settings.cfg"
const settings_folder = "res://controls/settings_types"
const SETTINGS = "SETTINGS"

static var initialized = false
static var config: ConfigFile

static var settings: Array[SettingResource] = []

static func _initialize():
	if initialized: return
	initialized = true
	
	#load setting resources (can't do this through DB right now since we need it on the main menu)
	var directory = DirAccess.open(settings_folder)
	var files = directory.get_files()
	for file in files:
		file = file.trim_suffix(".remap")
		if !file.ends_with(".tres"): continue
		var resource = load(settings_folder + "/" + file)
		if !(resource is SettingResource): continue
		settings.append(resource)
	
	#find cfg file
	config = ConfigFile.new()
	if config.load(cfg_file) == ERR_FILE_CANT_OPEN:
		printerr("Can't load settings!")
	else:
		if config.has_section(SETTINGS):
			#load cfg file
			for setting in settings:
				if config.has_section_key(SETTINGS, setting.name):
					setting.value = config.get_value(SETTINGS, setting.name)
				else:
					config.set_value(SETTINGS, setting.name, setting.default_setting)
					setting.value = setting.default_setting
		else:
			#make cfg file
			for setting in settings:
				config.set_value(SETTINGS, setting.name, setting.default_setting)
				setting.value = setting.default_setting

static func get_settings():
	_initialize()
	return settings

static func save_setting(setting:SettingResource):
	_initialize()
	config.set_value(SETTINGS, setting.name, setting.value)
	config.save(cfg_file)

static func get_setting(name:String):
	_initialize()
	return Global.find_by_func(settings, func(val): return val.name == name)
