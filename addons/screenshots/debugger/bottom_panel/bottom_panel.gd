@tool
extends Control

@export var nodes_to_save: Array[Node]

func _ready() -> void:
	load_nodes_from_config(nodes_to_save)
	setup_auto_save(nodes_to_save)

func save_nodes_to_config(p_nodes_to_save: Array[Node]) -> void:
	for node in p_nodes_to_save:
		var key = node.name
		var value = null
		
		if node is CheckBox:
			value = node.button_pressed
			%LocalData.settings.save("misc", key, value)
		
		if node is LineEdit:
			value = node.text
			%LocalData.settings.save("misc", key, value)

func load_nodes_from_config(p_nodes_to_load: Array[Node]) -> void:
	for node in p_nodes_to_load:
		var value = %LocalData.settings.load_value("misc", node.name)
		if value != null:
			if node is CheckBox:
				node.button_pressed = value
			
			if node is LineEdit:
				node.text = value

func setup_auto_save(nodes: Array[Node]) -> void:
	for node in nodes:
		if node is CheckBox:
			node.toggled.connect(func(_toggled): save_nodes_to_config([node]))
		if node is LineEdit:
			node.text_changed.connect(func(_new_text): save_nodes_to_config([node]))
		
func on_session_started() -> void:
	pass

func on_editor_debugger_plugin_capture(p_message, p_data) -> bool:
	if p_message == "screenshot:take":
		var buffer: PackedByteArray = p_data[0]
		var img := Image.new()
		var err := img.load_png_from_buffer(buffer)
		if err == OK:
			%CameraRoll.save_image(img, p_data[1], p_data[2])
		return true
	return false
