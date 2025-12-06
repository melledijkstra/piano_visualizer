extends Button

var play_icon = preload("res://assets/icons/play.svg")
var pause_icon = preload("res://assets/icons/pause.svg")

func _ready() -> void:
	if self.toggled:
		self.icon = pause_icon
	else:
		self.icon = play_icon

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		self.icon = pause_icon
	else:
		self.icon = play_icon

