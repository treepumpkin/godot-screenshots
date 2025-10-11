@tool
extends EditorPlugin

const SHUTTER_WINDOW = "res://addons/screenshots/autoload/shutter_window/shutter_window.tscn"

var m_editor_debugger_plugin : EditorDebuggerPlugin = preload("res://addons/screenshots/debugger/editor_debugger_plugin.gd").new()
var bottom_panel : Control

func _enable_plugin() -> void:
	add_autoload_singleton("Screenshots", SHUTTER_WINDOW)
	pass


func _disable_plugin() -> void:
	remove_autoload_singleton("Screenshots")
	pass


func _enter_tree() -> void:
	add_debugger_plugin(m_editor_debugger_plugin)
	pass


func _exit_tree() -> void:
	remove_debugger_plugin(m_editor_debugger_plugin)
	pass
