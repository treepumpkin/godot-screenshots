@tool
extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DeleteAllButton.icon = get_theme_icon("Remove", "EditorIcons")
	%DeleteAllButton.pressed.connect(_on_delete_all_button_pressed)
	%OpenFolderButton.icon = get_theme_icon("Filesystem", "EditorIcons")
	%OpenFolderButton.pressed.connect(_on_open_folder_button_pressed)
	
func _on_open_folder_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(%PathLineEdit.text))
	
func _on_delete_all_button_pressed() -> void:
	for c in %RollHFlowContainer.get_children():
		var path = c.path
		var err = OS.move_to_trash(ProjectSettings.globalize_path(path))
		if not err:
			c.queue_free()
