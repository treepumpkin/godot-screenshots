@tool
extends FoldableContainer

@export var local_data: Node


func _ready() -> void:
	%PickFolderButton.icon = get_theme_icon("FolderBrowse", "EditorIcons")
	%PickFolderButton.pressed.connect(func(): %FileDialog.show())
	%FileDialog.dir_selected.connect(_on_dir_selected)
	%FileDialog.current_dir = %PathLineEdit.text

	for c in %FormatsContainers.get_children():
		c.toggled.connect(_on_format_toggled)


func _on_dir_selected(path: String) -> void:
	%PathLineEdit.text = path


func _on_format_toggled(_toggled_on: bool) -> void:
	var has_pressed := false
	var has_unpressed := false

	for l: CheckBox in %FormatsContainers.get_children():
		if l.button_pressed:
			has_pressed = true
		else:
			has_unpressed = true

	if not has_pressed:
		%PNGCheckBox.button_pressed = true


func get_formats() -> Array[String]:
	var arr: Array[String] = []
	for child: CheckBox in %FormatsContainers.get_children():
		if child.button_pressed:
			arr.append(child.text)
	return arr
