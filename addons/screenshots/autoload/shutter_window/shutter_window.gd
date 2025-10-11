extends Window

## Godot addon that lets you rapidly take screenshots. Supports taking bursts in multiple resolutions, locales, and formats.

@export var _local_data: Node

## Fires before capture. Use this to hide debug UI elements.
signal burst_starting

## Fires after capture with metadata and image data.
signal image_captured(image: Image)

## Fires after the burst is completed. Use it to unhide debug UI elements.
signal burst_ended

var _input_action: String

func _ready() -> void:
	var saved_position = _local_data.settings.load_value("misc", "ShutterWindowPosition")
	if saved_position:
		position = saved_position
	old_position = position
	var only_run_in_editor = _local_data.settings.load_value("misc", "OnlyRunInEditorCheckBox", true)
	
	if only_run_in_editor and not OS.has_feature("editor"):
		queue_free()
		return
		
	visible = _local_data.settings.load_value("misc", "ShowShutterCheckBox", true)
	_input_action = _local_data.settings.load_value("misc", "InputActionLineEdit", "")
	%ShutterButton.pressed.connect(take_burst)
	close_requested.connect(_on_close_requested)
	
	
func _on_close_requested() -> void:
	hide()
	
var old_position : Vector2i
func _input(event: InputEvent) -> void:
	if old_position != position:
		_local_data.settings.save("misc", "ShutterWindowPosition", position)
	old_position = position
	if not InputMap.has_action(_input_action):
		return
	if event.is_action_pressed(_input_action):
		take_burst()


## Takes one or more screenshots (a burst) using settings specified in the Debugger panel
func take_burst() -> void:
	var old_position = position
	_local_data.settings.load_config()
	burst_starting.emit()
	var pause_game = _local_data.settings.load_value("misc", "PausesGameCheckBox", true)
	var shutter_was_visible = visible
	var sizes = _local_data.settings.load_value("misc", "Sizes", [])
	var locales = _local_data.settings.load_value("misc", "Locales", ["none"])
	var previous_locale = TranslationServer.get_locale()
	hide()
	
	var tree = get_tree()
	var game_was_paused = tree.paused
	if pause_game:
		tree.paused = true
	var prev_size = DisplayServer.window_get_size()
	
	
	
	# Take screenshots for each configured size
	for s in sizes:
		DisplayServer.window_set_size(s)
		await get_tree().create_timer(0.01).timeout
		
		for locale in locales:
			var locale_to_set = locale
			
			if locale == "none":
				locale_to_set = previous_locale
				
			TranslationServer.set_locale(locale_to_set)
			await get_tree().process_frame
			save_image()
	
	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(prev_size)
	
	
	tree.paused = game_was_paused
	visible = shutter_was_visible
	burst_ended.emit()
	print_rich("[color=green][Screenshots] Done![/color]")
	position = old_position

func save_image() -> void:
	var locale = TranslationServer.get_locale()
	var timestamp = Time.get_time_string_from_system()
	var play_shutter_sounds = _local_data.settings.load_value("misc", "ShutterSoundsCheckBox", true)
	# Save the screenshot
	var image = get_parent().get_viewport().get_texture().get_image()
	image_captured.emit(image)
	
	if play_shutter_sounds:
		%AudioStreamPlayer.play()
	var save_folder: String = _local_data.settings.load_value("misc", "PathLineEdit", "user://screenshots")
	var project_title = ProjectSettings.get_setting("application/config/name")
	var screenshot_size = image.get_size()
	
	# Build the save path with optional subfolders
	var target_folder = save_folder
	if _local_data.settings.load_value("misc", "UseSubFoldersCheckBox", false):
		# Create subfolder structure: Project_timestamp/locale/resolution
		var timestamp_folder = "%s_%s" % [project_title, timestamp.replace(":", "-")]
		var locale_folder = locale
		var resolution_folder = "%dx%d" % [screenshot_size.x, screenshot_size.y]
		
		target_folder = save_folder.path_join(timestamp_folder).path_join(locale_folder).path_join(resolution_folder)
	
	# Ensure target folder exists
	if not DirAccess.dir_exists_absolute(target_folder):
		DirAccess.make_dir_recursive_absolute(target_folder)
	
	var formats = {
		"PNGCheckBox": ["png", image.save_png, true],
		"JPGCheckBox": ["jpg", image.save_jpg, false],
		"WEBPCheckBox": ["webp", image.save_webp, false]
	}
	
	for setting_key in formats:
		var default = formats[setting_key][2]
		if _local_data.settings.load_value("misc", setting_key, default):
			var extension = formats[setting_key][0]
			var save_method = formats[setting_key][1]
			
			var filename: String
			if _local_data.settings.load_value("misc", "UseSubFoldersCheckBox", false):
				filename = "%s_%s" % [project_title, timestamp.replace(":", "-")]
			else:
				filename = "%s_%s_%s_%dx%d" % [project_title, timestamp.replace(":", "-"), locale, screenshot_size.x, screenshot_size.y]
			
			var file_path = target_folder.path_join("%s.%s" % [filename, extension])
			
			# Get unique filepath to avoid overwriting
			file_path = get_unique_filepath(file_path)
			
			save_method.call(file_path)
			EngineDebugger.send_message("screenshot:taken", [file_path, timestamp, locale])
			
			print_rich("[Screenshots] Saved at: [url=%s]%s[/url]" % [ProjectSettings.globalize_path(file_path.get_base_dir()), file_path])
			
func get_unique_filepath(base_path: String) -> String:
	if not FileAccess.file_exists(base_path):
		return base_path
	
	var dir = base_path.get_base_dir()
	var filename = base_path.get_file().get_basename()
	var extension = base_path.get_extension()
	
	var counter = 1
	var new_path = "%s/%s_%d.%s" % [dir, filename, counter, extension]
	
	while FileAccess.file_exists(new_path):
		counter += 1
		new_path = "%s/%s_%d.%s" % [dir, filename, counter, extension]
	
	return new_path
		
