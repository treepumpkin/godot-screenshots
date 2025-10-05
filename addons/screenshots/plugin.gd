@tool
extends EditorPlugin

const SHUTTER_WINDOW = "res://addons/screenshots/autoload/shutter_window/shutter_window.tscn"

var m_editor_debugger_plugin : EditorDebuggerPlugin = preload("res://addons/screenshots/debugger/editor_debugger_plugin.gd").new()
var bottom_panel : Control

func _enter_tree():
	add_debugger_plugin(m_editor_debugger_plugin)
	add_autoload_singleton("Screenshots", SHUTTER_WINDOW)

func _exit_tree():
	remove_debugger_plugin(m_editor_debugger_plugin)
	remove_autoload_singleton("Screenshots")
