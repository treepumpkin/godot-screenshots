@tool
extends FoldableContainer

const SIZE = preload("res://addons/screenshots/debugger/bottom_panel/size/size.tscn")
@onready var local_data = %LocalData
@export var sizes_container: FlowContainer


func _ready() -> void:
	sizes_container.child_exiting_tree.connect(_on_size_removed)
	sizes_container.child_entered_tree.connect(_on_size_added)

	var def_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var def_height = ProjectSettings.get_setting("display/window/size/viewport_height")

	for s in local_data.settings.load_value("misc", "Sizes", [Vector2i(def_width, def_height)]):
		var new_size = SIZE.instantiate()
		new_size.set_resolution(s)
		sizes_container.add_child(new_size)


func _on_size_removed(node: Node) -> void:
	await node.tree_exited

	if not sizes_container:
		return

	if sizes_container.get_child_count() == 1:
		sizes_container.get_child(0).set_trash_button_disabled(true)

	_save_to_config()
	sizes_container.get_child(-1).set_add_button_visibility(true)


func _on_size_added(node: Node) -> void:
	if not node.resolution_edited.is_connected(_save_to_config):
		node.resolution_edited.connect(_save_to_config)
	if sizes_container.get_child_count() >= 1:
		for c in sizes_container.get_children():
			c.set_trash_button_disabled(false)
			c.set_add_button_visibility(false)

	_save_to_config()
	sizes_container.get_child(-1).set_add_button_visibility(true)


func _save_to_config() -> void:
	local_data.settings.save("misc", "Sizes", get_sizes())


func get_sizes() -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	for child in sizes_container.get_children():
		arr.append(child.get_resolution())
	return arr
