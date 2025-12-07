extends Node2D

# --- Configuration ---
@export var outro_time: float = 2.0 # how long to wait before quitting after the song ends

func _on_finish():
	# we wait some seconds before quitting to finish any animations and effects still running
	await get_tree().create_timer(outro_time).timeout
	get_tree().quit()
