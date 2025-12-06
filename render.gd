extends Node2D

# --- Configuration ---
@export_file("*.mid") var midi_file_path: String = "res://input/clair_de_lune.mid"
@export var note_scene: PackedScene = preload("res://components/Note.tscn")
@export var fall_speed: float = 150.0 # Pixels per second

# --- Imports & Resources ---
var SongDataScript = preload("res://song_data.gd")

# --- UI Elements ---
@onready var keyboard: Keyboard = %VisualKeyboard
@onready var song_info: Label = %SongInfo
@onready var simulation_info: Label = %SimulationInfo

# --- State ---
var is_playing: bool = true
var song_data: SongData
var active_notes: Array[NoteNode] = []
var spawn_index: int = 0

# --- Timing of the simulation ---
## Current time in seconds where the simulation currently is
var current_time: float = -3.0 # Start negative to give a "Get Ready" pause

# Calculated property: How many seconds it takes to fall from top to target
var fall_duration: float:
	get:
		var target_y = get_viewport().size.y
		if keyboard:
			target_y -= keyboard.size.y
		return target_y / fall_speed

func _ready():
	midi_file_path = SceneSwitcher.get_param("selected_file", midi_file_path)
	# 1. Load MIDI file
	song_data = SongDataScript.new(midi_file_path, true)
	print("Loaded ", song_data.notes.size(), " notes.")

	# 2. UI Setup - Do this after heavy calculations of the MIDI file
	update_song_info()

func _process(delta):
	if not is_playing or not song_data.is_parsed: return
	
	# - Advance time
	current_time += delta

	# - Move notes
	move_notes()
	
	# - Check for notes to spawn
	var notes: Array[NoteData] = song_data.notes
	var look_ahead_time = current_time + fall_duration
	
	while spawn_index < notes.size():
		var note = notes[spawn_index]
		
		if note.start_time <= look_ahead_time:
			spawn_note(note)
			spawn_index += 1
		else:
			break

	# we reached the end of the song_data, check if there are still notes on the screen
	if spawn_index >= notes.size()\
	and get_tree().get_nodes_in_group("notes").size() == 0:
		finish()

	update_simulation_info()

func finish():
	# we wait some seconds before quitting to finish any animations and effects still running
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func spawn_note(note_data: NoteData):
	if note_scene == null: return
	if keyboard == null: return

	var instance = note_scene.instantiate()
	var label = Label.new()
	label.text = seconds_to_time_string(note_data.start_time)
	label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	label.add_theme_font_size_override("font_size", 15)
	instance.add_child(label)
	instance.add_to_group("notes")
	add_child(instance)
	
	# Get layout from keyboard, this makes sure notes match up with the keyboard
	var key_center_x = keyboard.get_key_x(note_data.pitch)
	var key_width = keyboard.get_key_width(note_data.pitch)
	
	# Setup note
	instance.setup(note_data, key_width, fall_speed)

	# Adjust position
	var y_pos = calculate_note_y(note_data)

	# Centering X (Note.gd setup creates a rect of size.x)
	var x_pos = key_center_x - (instance.size.x / 2.0)

	instance.position = Vector2(x_pos, y_pos)

	active_notes.append(instance)

func move_notes():
	for note in get_tree().get_nodes_in_group("notes"):
		var node := note as NoteNode
		if not note: continue
		var new_y = calculate_note_y(node.data)
		node.position.y = new_y

func calculate_note_y(note_data: NoteData) -> float:
	var target_y = get_viewport().size.y
	if keyboard:
		target_y -= keyboard.size.y
	var new_y = target_y - fall_speed * (note_data.start_time - current_time)
	return new_y

func _on_speed_slider_value_changed(value: float) -> void:
	fall_speed = value
	for node in get_tree().get_nodes_in_group("notes"):
		var note := node as NoteNode
		if not note: continue
		note.speed = fall_speed

func _on_timeline_slider_value_changed(_value: float) -> void:
	# current_time = value;
	pass

func update_simulation_info():
	if simulation_info == null: return
	simulation_info.text = "Speed: {speed}\nTime: {time}".format({
		"speed": fall_speed,
		"time": seconds_to_time_string(current_time)
	})

func seconds_to_time_string(seconds_input: float) -> String:
	var negative = ""
	if seconds_input < 0:
		negative = "-"
	seconds_input = abs(seconds_input)
	var milliseconds = fmod(seconds_input, 1) * 100
	var seconds = fmod(seconds_input, 60)
	var minutes = seconds_input / 60
	return "%s%02d:%02d:%02d" % [negative, minutes, seconds, milliseconds]

func update_song_info():
	if song_info == null: return
	song_info.text = "Notes: {notes}\nTotal song time: {song_duration}"\
		.format({
			"notes": str(song_data.notes.size()),
			"song_duration": song_data.song_duration_formatted()
		})

func _on_play_pause_btn_toggled(toggle_state: bool) -> void:
	is_playing = toggle_state
