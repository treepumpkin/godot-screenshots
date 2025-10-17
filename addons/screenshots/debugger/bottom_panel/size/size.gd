@tool
extends HBoxContainer

signal resolution_edited
@export var preset_option_button: OptionButton

var presets: Dictionary[String, Vector2i] = {
	"iPhone 6.9\" (portrait)": Vector2i(1320, 2868),
	"iPhone 6.9\" (landscape)": Vector2i(2868, 1320),
	"iPad 13\" (portrait)": Vector2i(2064, 2752),
	"iPad 13\" (landscape)": Vector2i(2752, 2064),
}


func _ready() -> void:
	var i = 0
	preset_option_button.clear()
	for preset in presets:
		preset_option_button.add_item(preset)
		preset_option_button.set_item_metadata(i, presets[preset])
		i += 1
	preset_option_button.add_item("Custom")
	preset_option_button.item_selected.connect(_on_preset_selected)

	if preset_option_button.selected == -1:
		preset_option_button.select(0)
		_on_preset_selected(0)

	%XLineEdit.text_changed.connect(_on_resolution_edited.bind("x"))
	%YLineEdit.text_changed.connect(_on_resolution_edited.bind("y"))
	%AddButton.pressed.connect(_on_add_button_pressed)
	%AddButton.icon = get_theme_icon("Add", "EditorIcons")
	%XLabel.add_theme_color_override("font_color", get_theme_color("property_color_x", "Editor"))
	%YLabel.add_theme_color_override("font_color", get_theme_color("property_color_y", "Editor"))
	%PixelsLabel.add_theme_color_override("font_color", get_theme_color("disabled_font_color", "Editor"))
	%PixelsLabel2.add_theme_color_override("font_color", get_theme_color("disabled_font_color", "Editor"))
	%TrashButton.pressed.connect(_on_trash_button_pressed)
	%TrashButton.icon = get_theme_icon("Remove", "EditorIcons")


func _on_trash_button_pressed() -> void:
	queue_free()


func set_trash_button_disabled(p_disabled: bool) -> void:
	%TrashButton.disabled = p_disabled


func set_add_button_visibility(p_visible: bool) -> void:
	%AddButton.visible = p_visible


func _on_add_button_pressed() -> void:
	var size_panel = load("res://addons/screenshots/debugger/bottom_panel/size/size.tscn")
	get_parent().add_child(size_panel.instantiate())
	$AddButton.hide()


func _on_preset_selected(idx: int) -> void:
	var resolution: Vector2i = preset_option_button.get_item_metadata(idx)
	if not resolution:
		return

	%XLineEdit.text = str(resolution.x)
	%YLineEdit.text = str(resolution.y)
	resolution_edited.emit()


func set_resolution(p_resolution: Vector2i) -> void:
	%XLineEdit.text = str(p_resolution.x)
	%YLineEdit.text = str(p_resolution.y)
	select_preset_option(p_resolution)


func select_preset_option(resolution: Vector2i) -> void:
	if not is_node_ready():
		await ready
	var idx = preset_option_button.item_count - 1
	for i in range(0, preset_option_button.item_count):
		var button_res = preset_option_button.get_item_metadata(i)
		if button_res == resolution:
			idx = i
	preset_option_button.select(idx)


func get_resolution() -> Vector2i:
	var res: Vector2i
	res.x = int(%XLineEdit.text)
	res.y = int(%YLineEdit.text)
	return res


func _on_resolution_edited(new_text: String, axis: String) -> void:
	# Remove all non-digit characters
	var filtered := ""
	for c in new_text:
		if c.is_valid_int():
			filtered += c

	# Update the correct line edit only if text was modified
	if axis == "x":
		if %XLineEdit.text != filtered:
			%XLineEdit.text = filtered
	elif axis == "y":
		if %YLineEdit.text != filtered:
			%YLineEdit.text = filtered

	select_preset_option(get_resolution())
	resolution_edited.emit()
