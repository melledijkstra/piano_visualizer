extends Node

################################################
## Role: The "Brain". It manages the song data and the clock. It doesn't know about pixels, sprites, or labels.
## * Responsibility: Loads the MIDI file, tracks current_time, handles is_playing state, and playback speed.
## * Signals: Emits time_updated(current_time), song_loaded(song_data), finished.
## * SOLID win: SRP (only handles time/data). OCP (you can change how time works—e.g., add rewinding—without breaking the visuals).
################################################

@export_file("*.mid") var midi_file_path: String = "res://input/clair_de_lune.mid"

signal time_updated(current_time: float)
signal song_loaded(song_data: Song)

# --- State ---
var _is_parsed: bool = false
var is_playing: bool = true
var song: Song = null

## Current time in seconds where the simulation currently is
var current_time: float = -2.0 # Start negative to give a "Get Ready" pause

func _ready() -> void:
	# grabs the midi file path from the scene switcher parameters
	# if no file was selected then we use the default midi file
	midi_file_path = SceneSwitcher.get_param("selected_file", midi_file_path)
	self.song = parse(midi_file_path)
	_is_parsed = true
	print("Loaded %d notes. (duration: %s seconds)" % [song.notes.size(), song.duration_formatted()])
	emit_signal("song_loaded", song)

func parse(file_path: String) -> Song:
	var midi_parser := MidiFileParser.load_file(file_path)
	var notes := MidiPreprocessor.preprocess(midi_parser)
	var result = Song.new(notes)
	_is_parsed = true
	return result

func _process(delta: float) -> void:
	if not is_playing or not _is_parsed: return

	# - Advance time
	current_time += delta
	emit_signal("time_updated", current_time)

func _on_play_pause_btn_toggled(toggle_state: bool) -> void:
	is_playing = toggle_state

func _on_timeline_slider_value_changed(value: float) -> void:
	current_time = value
	emit_signal("time_updated", current_time)