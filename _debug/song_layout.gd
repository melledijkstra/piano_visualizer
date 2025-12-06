extends Node2D

# --- Export Variables ---
@export_file("*.mid") var midi_file_path: String = "res://input/chromatic_scales_test.mid"
@export var timeline: Control

# --- UI ---
@onready var song_info: RichTextLabel = $UI/SongInfo

# --- Internal Variables ---
var all_note_nodes: Array[LayoutNote] = []
var current_zoom: float = 100.0 # Pixels per second
var song_data: SongData

func _ready():
	print("--- Song Layout: Initializing ---")
	
	# 2. Load and Parse MIDI
	_load_midi_data()

func _load_midi_data():
	if not FileAccess.file_exists(midi_file_path):
		printerr("Error: MIDI file not found at ", midi_file_path)
		return

	print("Debug: Loading MIDI file: ", midi_file_path)
	
	# Use the existing MidiFileParser static method
	var parser = MidiFileParser.load_file(midi_file_path)
	if parser == null:
		printerr("Error: Failed to parse MIDI file.")
		return
		
	# Use the Preprocessor to get flat NoteData
	song_data = SongData.new(midi_file_path, true)
	print("Debug: Parsed ", song_data.notes.size(), " notes.")

	show_song_info()
	
	_generate_layout(song_data.notes)

func show_song_info():
	if song_info == null or song_data.is_empty():
		return
	song_info.text = \
	"Notes: " + str(song_data.notes.size()) + \
	"\nTotal song time: " + song_data.total_song_duration

func reset():
	# Clear existing
	for child in timeline.get_children():
		child.queue_free()
	all_note_nodes.clear()

func _generate_layout(notes: Array[NoteData]):
	self.reset()
	
	if notes.is_empty():
		print("Debug: No notes to display.")
		return
		
	# Calculate Layout Dimensions
	# Standard piano height calculation
	var layout_height = get_viewport_rect().size.y
	var lane_height = layout_height / Globals.KEY_COUNT
	
	print("Debug: Spawning notes with lane height: ", lane_height)
	
	# Spawn Notes
	var max_x = 0.0
	
	for data in notes:
		var note_elem = LayoutNote.new()
		timeline.add_child(note_elem)
		note_elem.setup(data, lane_height, current_zoom)
		all_note_nodes.append(note_elem)
		
		# Track width for the container size
		var end_of_note = note_elem.position.x + note_elem.size.x
		if end_of_note > max_x:
			max_x = end_of_note

	# Update Content Container Size
	timeline.custom_minimum_size.x = max_x + 500.0 # Add padding
	print("Debug: Layout generation complete. Total width: ", max_x)

func _on_zoom_changed(value: float):
	print("Debug: Zoom changed to ", value)
	current_zoom = value
	
	var max_x = 0.0
	
	# Update all notes
	for note_elem in all_note_nodes:
		note_elem.update_zoom(current_zoom)
		
		var end = note_elem.position.x + note_elem.size.x
		if end > max_x:
			max_x = end
			
	# Update container size to allow scrolling to the new end
	if timeline:
		timeline.custom_minimum_size.x = max_x + 500.0
