@tool
extends EditorDebuggerPlugin

var session_id_to_editor_panel: Dictionary = { }


func _setup_session(p_session_id: int) -> void:
	var editor_panel: Control = preload("res://addons/screenshots/debugger/bottom_panel/bottom_panel.tscn").instantiate()
	var editor_debugger_session: EditorDebuggerSession = get_session(p_session_id)

	var _success: int = editor_debugger_session.started.connect(editor_panel.on_session_started)
	editor_debugger_session.add_session_tab(editor_panel)
	session_id_to_editor_panel[p_session_id] = editor_panel


func _has_capture(p_prefix: String) -> bool:
	return p_prefix == "screenshot"


func _capture(p_message: String, p_data: Array, p_session_id: int) -> bool:
	var editor_panel: Control = session_id_to_editor_panel[p_session_id]
	return editor_panel.on_editor_debugger_plugin_capture(p_message, p_data)
