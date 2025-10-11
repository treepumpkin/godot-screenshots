@tool
extends Node
var settings: LocalFile

func _ready():
	settings = LocalFile.new("res://addons/screenshots/settings.cfg")

class LocalFile:
	signal value_changed(section: String, key: String, new_value)
	
	var config: ConfigFile
	var file_path: String
	
	func _init(path: String):
		file_path = path
		config = ConfigFile.new()
		load_config()
	
	func load_config():
		var err = config.load(file_path)
		if err != OK:
			# File doesn't exist or couldn't be loaded, that's fine
			# We'll create it when we first save
			pass
	
	func save(section: String, key: String, value):
		var old_value = null
		var has_existing_key = config.has_section_key(section, key)
		
		if has_existing_key:
			old_value = config.get_value(section, key)
		
		# Only save and emit if the value is different
		if not has_existing_key or old_value != value:
			config.set_value(section, key, value)
			var err = config.save(file_path)
			if err != OK:
				push_error("Failed to save config file " + file_path + ": " + str(err))
			else:
				value_changed.emit(section, key, value)
	
	func load_value(section: String, key: String, default_value = null):
		# Check if the key exists first to avoid C++ errors
		if config.has_section_key(section, key):
			return config.get_value(section, key)
		else:
			# Key doesn't exist, save the default value
			if default_value != null:
				save(section, key, default_value)
			return default_value
	
	
	func has_key(section: String, key: String) -> bool:
		return config.has_section_key(section, key)
	
	func has_section(section: String) -> bool:
		return config.has_section(section)
	
	# Get all values from a section
	func get_section(section: String) -> Dictionary:
		if config.has_section(section):
			return config.get_section_values(section)
		return {}
	
	# Get all sections
	func get_sections() -> PackedStringArray:
		return config.get_sections()
	
	# Remove a key
	func remove_key(section: String, key: String):
		config.erase_section_key(section, key)
		var err = config.save(file_path)
		if err != OK:
			push_error("Failed to save config file " + file_path + ": " + str(err))
	
	# Remove an entire section
	func remove_section(section: String):
		config.erase_section(section)
		var err = config.save(file_path)
		if err != OK:
			push_error("Failed to save config file " + file_path + ": " + str(err))
	
	# Clear entire file
	func clear_all():
		config.clear()
		var err = config.save(file_path)
		if err != OK:
			push_error("Failed to clear config file " + file_path + ": " + str(err))
