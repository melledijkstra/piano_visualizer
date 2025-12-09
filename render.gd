extends Node2D

# --- Configuration ---
@export var outro_time: float = 2.0 # how long to wait before quitting after the song ends

func _ready() -> void:
	# When in movie writer mode, remove group that we don't want in the final image
	# Also this frees up resources
	if OS.has_feature("movie"):
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFAULT, "hidden_from_movie", "queue_free")

func _on_finish():
	# we wait some seconds before quitting to finish any animations and effects still running
	await get_tree().create_timer(outro_time).timeout
	get_tree().quit()
