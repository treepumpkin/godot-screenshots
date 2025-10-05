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
	visible = _local_data.settings.load_value("misc", "ShowShutterCheckBox", true)
	_input_action = _local_data.settings.load_value("misc", "InputActionLineEdit", "")
	%ShutterButton.pressed.connect(take_burst)
	close_requested.connect(_on_close_requested)
	
func _on_close_requested() -> void:
	hide()
	
func _input(event: InputEvent) -> void:
	if not InputMap.has_action(_input_action):
		return
	if event.is_action_pressed(_input_action):
		take_burst()

## Takes one or more screenshots (a burst) using settings specified in the Debugger panel
func take_burst() -> void:
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
	var timestamp = Time.get_time_string_from_system()
	
	
	# Take screenshots for each configured size
	for s in sizes:
		DisplayServer.window_set_size(s)
		await get_tree().create_timer(0.01).timeout
		
		for locale in locales:
			if not locale == "none":
				TranslationServer.set_locale(locale)
			await get_tree().process_frame
			
			_send_viewport_texture_to_debugger(timestamp, TranslationServer.get_locale())
	
	TranslationServer.set_locale(previous_locale)
	DisplayServer.window_set_size(prev_size)
	
	# Print clickable paths
	print_rich("[color=green][Screenshots] Done! (%s)[/color]" % timestamp)
	
	tree.paused = game_was_paused
	visible = shutter_was_visible
	burst_ended.emit()

func _send_viewport_texture_to_debugger(timestamp: String, locale: String) -> void:
	var play_shutter_sounds = _local_data.settings.load_value("misc", "ShutterSoundsCheckBox", true)
	# Save the screenshot
	var image = get_parent().get_viewport().get_texture().get_image()
	EngineDebugger.send_message("screenshot:take", [image.save_png_to_buffer(), timestamp, locale])
	image_captured.emit(image)
	
	if play_shutter_sounds:
		%AudioStreamPlayer.play()
