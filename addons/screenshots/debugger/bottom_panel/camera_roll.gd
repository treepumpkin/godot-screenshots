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
