@tool
extends VBoxContainer

@export var texture : Texture2D
@export var locale: String
@export var path: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Button.icon = texture
	var resolution = Vector2i(texture.get_size())
	$Label.text = path.get_file()
	var globalized_path = ProjectSettings.globalize_path(path)
	$Button.pressed.connect(func(): OS.shell_open(globalized_path))
	
	for c : Control in get_children():
		c.tooltip_text = "%s\n%sx%s\nLocale: %s" % [path.get_file(), resolution.x, resolution.y, locale]
