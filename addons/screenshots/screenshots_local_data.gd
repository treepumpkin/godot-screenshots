@tool
extends Node

var settings: LocalFile

func _ready():
	settings = LocalFile.new("res://addons/screenshots/settings.cfg")

class LocalFile:
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
		config.set_value(section, key, value)
		var err = config.save(file_path)
		if err != OK:
			push_error("Failed to save config file " + file_path + ": " + str(err))
	
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
