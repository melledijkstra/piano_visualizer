extends Control

var selected_file: String = ""

@onready var scene_switcher = $SceneSwitcher

func _on_file_dialog_file_selected(path: String) -> void:
	selected_file = path
	print("Selected file: ", selected_file)
	scene_switcher.switch("res://render.tscn", {"selected_file": selected_file})
