@tool
extends VBoxContainer

@export var local_data: Node
@export var previews_container: Control

const SCREENSHOT_PREVIEW = preload("res://addons/screenshots/debugger/bottom_panel/screenshot_preview/screenshot_preview.tscn")

func _ready() -> void:
	%RollPanelContainer.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "ItemListSecondary"))
	%CameraRollIcon.texture = get_theme_icon("CameraTexture", "EditorIcons")
	for filepath in local_data.settings.load_value("misc", "CameraRollPreviews", []):
		var img = Image.new()
		img = img.load_from_file(filepath)
		
		if img == null:
			continue
		
		var s = SCREENSHOT_PREVIEW.instantiate()
		s.texture = ImageTexture.create_from_image(img)
		s.path = filepath
		s.locale = ""
		previews_container.add_child(s)
	
	local_data.settings.save("misc", "CameraRollPreviews", get_all_previews_paths())
	previews_container.child_entered_tree.connect(_on_preview_added)
	previews_container.child_exiting_tree.connect(_on_preview_removed)
	
func _on_preview_added(preview: Node) -> void:
	local_data.settings.save("misc", "CameraRollPreviews", get_all_previews_paths())
	pass
	
func _on_preview_removed(preview: Node) -> void:
	await preview.tree_exited
	local_data.settings.save("misc", "CameraRollPreviews", get_all_previews_paths())
	pass
	
func get_all_previews_paths() -> Array[String]:
	var arr : Array[String] = []
	for preview in previews_container.get_children():
		arr.append(preview.path)
	return arr

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
		
func save_image(image: Image, timestamp: String, locale: String) -> void:
	var save_folder: String = %PathLineEdit.text
	var project_title = ProjectSettings.get_setting("application/config/name")
	var screenshot_size = image.get_size()
	
	# Build the save path with optional subfolders
	var target_folder = save_folder
	if local_data.settings.load_value("misc", "UseSubFoldersCheckBox", false):
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
		if local_data.settings.load_value("misc", setting_key, default):
			var extension = formats[setting_key][0]
			var save_method = formats[setting_key][1]
			
			var filename: String
			if local_data.settings.load_value("misc", "UseSubFoldersCheckBox", false):
				filename = "%s_%s" % [project_title, timestamp.replace(":", "-")]
			else:
				filename = "%s_%s_%s_%dx%d" % [project_title, timestamp.replace(":", "-"), locale, screenshot_size.x, screenshot_size.y]
			
			var file_path = target_folder.path_join("%s.%s" % [filename, extension])
			
			# Get unique filepath to avoid overwriting
			file_path = get_unique_filepath(file_path)
			
			save_method.call(file_path)
			
			var s = SCREENSHOT_PREVIEW.instantiate()
			s.texture = ImageTexture.create_from_image(image)
			s.path = file_path
			s.locale = locale
			previews_container.add_child(s)
			print_rich("[Screenshots] Saved at: [url=%s]%s[/url]" % [ProjectSettings.globalize_path(file_path.get_base_dir()), file_path])
