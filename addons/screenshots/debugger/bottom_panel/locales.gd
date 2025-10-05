@tool
extends FoldableContainer

@onready var locales_container = $VBoxContainer/HFlowContainer
@export var local_data: Node
@export var select_all_button: Button
@export var deselect_all_button: Button

func _ready() -> void:
	var saved_locales = local_data.settings.load_value("misc", "Locales", ["none"])
	for l in TranslationServer.get_loaded_locales():
		var n = CheckBox.new()
		n.text = l
		if saved_locales.has(l):
			n.button_pressed = true
		locales_container.add_child(n)
	
	for c : CheckBox in locales_container.get_children():
		c.toggled.connect(_on_locale_toggled)
		
	select_all_button.pressed.connect(_set_all_locales_pressed.bind(true))
	deselect_all_button.pressed.connect(_set_all_locales_pressed.bind(false))
	select_all_button.icon = get_theme_icon("ThemeSelectAll", "EditorIcons")
	deselect_all_button.icon = get_theme_icon("ThemeDeselectAll", "EditorIcons")
	
func get_locales() -> Array[String]:
	var arr: Array[String] = []
	for child : CheckBox in locales_container.get_children():
		if child.button_pressed:
			arr.append(child.text)
	return arr
	
func _set_all_locales_pressed(pressed: bool) -> void:
	for l : CheckBox in locales_container.get_children():
		l.button_pressed = pressed

func _on_locale_toggled(_toggled_on: bool) -> void:
	var has_pressed := false
	var has_unpressed := false

	for l: CheckBox in locales_container.get_children():
		if l.button_pressed:
			has_pressed = true
		else:
			has_unpressed = true

	# "Deselect all" should only be enabled if at least one is pressed
	deselect_all_button.disabled = not has_pressed
	if not has_pressed:
		%NoneLocaleCheckBox.button_pressed = true
	
	# "Select all" should only be enabled if at least one is unpressed
	select_all_button.disabled = not has_unpressed
	_save_to_config()
	
func _save_to_config() -> void:
	local_data.settings.save("misc", "Locales", get_locales())
