extends MarginContainer

enum {
	THEME_DARK,
	THEME_LIGHT
}


@export var theme_dark: Theme
@export var theme_light: Theme


func _set_theme(value: Theme) -> void:
	print("set theme: ", value)
	EditorManager.set_ui_theme(value)
	WhiteboardManager.set_whiteboard_theme(value)

func _on_theme_button_item_selected(index: int) -> void:
	match index:
		THEME_DARK:
			_set_theme(theme_dark)
		THEME_LIGHT:
			_set_theme(theme_light)
