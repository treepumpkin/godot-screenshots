@tool
extends VBoxContainer

@export var local_data: Node
@export var previews_container: Control

const SCREENSHOT_PREVIEW = preload("res://addons/screenshots/debugger/bottom_panel/screenshot_preview/screenshot_preview.tscn")

var roll_directory : String
func _ready() -> void:
	%RollPanelContainer.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "ItemListSecondary"))
	%CameraRollIcon.texture = get_theme_icon("CameraTexture", "EditorIcons")
	roll_directory = local_data.settings.load_value("misc", "PathLineEdit", "user://screenshots")
	%DirectoryWatcher.add_scan_directory(roll_directory)
	local_data.settings.value_changed.connect(_on_local_data_changed)
	%DirectoryWatcher.files_deleted.connect(_on_files_deleted)

func _on_files_deleted(files: PackedStringArray) -> void:
	for file in files:
		for preview in previews_container.get_children():
			if ProjectSettings.globalize_path(preview.path) == ProjectSettings.localize_path(file):
				preview.queue_free()

func _on_local_data_changed(section: String, key: String, new_value) -> void:
	if not key == "PathLineEdit":
		return
	
	%DirectoryWatcher.remove_scan_directory(roll_directory)
	roll_directory = new_value
	%DirectoryWatcher.add_scan_directory(roll_directory)
		
	
func add_preview(file_path: String, timestamp: String, locale: String) -> void:
	var s = SCREENSHOT_PREVIEW.instantiate()
	var image = Image.load_from_file(file_path)
	var texture = ImageTexture.create_from_image(image)
	s.texture = texture
	
	s.path = file_path
	s.locale = locale
	previews_container.add_child(s)
	
func get_all_previews_paths() -> Array[String]:
	var arr : Array[String] = []
	for preview in previews_container.get_children():
		arr.append(preview.path)
	return arr
