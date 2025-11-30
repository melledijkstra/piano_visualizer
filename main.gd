extends Node2D

# --- Configuration ---
@export var note_scene: PackedScene  # Drag Note.tscn here in Inspector
@export var fall_speed: float = 150.0 # Pixels per second

# --- State ---
var midi_processor = preload("res://midi_preprocessor.gd").new()
var parser: MidiFileParser
var song_data: Array = []
var spawn_index: int = 0
var current_time: float = -3.0 # Start negative to give a "Get Ready" pause

var screen_height: float
var screen_width: float

# Calculated property: How many seconds it takes to fall from top to bottom
var fall_duration: float:
	get: return screen_height / fall_speed

func _ready():
	print('has movie: ', OS.has_feature('movie'))
	var viewport_size = get_viewport().size
	
	screen_height = viewport_size.y
	screen_width = viewport_size.x
	
	# 1. Load your specific MIDI file here
	# (Ensure you are using the correct file loading logic as before)
	parser = MidiFileParser.load_file("res://input/clair_de_lune.mid")
	
	song_data = midi_processor.parse(parser)
	print("Loaded ", song_data.size(), " notes.")

func _process(delta):
	if song_data.is_empty(): return
	
	# 1. Advance time
	current_time += delta
	
	# 2. Check for notes to spawn
	# We spawn a note if: Note Start Time <= Current Time + Fall Duration
	# This ensures it hits the bottom exactly when 'current_time' matches 'start_time'
	
	var look_ahead_time = current_time + fall_duration
	
	while spawn_index < song_data.size():
		var note = song_data[spawn_index]
		
		if note.start_time <= look_ahead_time:
			_spawn_note(note)
			spawn_index += 1
		else:
			# The next note is too far in the future, stop checking for this frame
			break

func _spawn_note(note_data: NoteData):
	if note_scene == null: return

	var instance = note_scene.instantiate()
	add_child(instance)
	
	# Calculate Lane (Standard Piano has 88 keys, usually MIDI 21 to 108)
	var key_count = 88.0
	var lane_width = screen_width / key_count
	
	# MIDI pitch 21 is the lowest A on a piano.
	# We clamp to ensure notes outside 88 keys don't crash us.
	var key_index = clamp(note_data.pitch - 21, 0, 87)
	
	var x_pos = key_index * lane_width
	# var start_y = -instance.size.y # Start just above screen?
	# Actually, we set Y based on exact timing to fix frame-jitter
	# distance_to_fall = (note_time - current_time) * speed
	var dist = (note_data.start_time - current_time) * fall_speed
	var y_pos = screen_height - dist - (note_data.duration * fall_speed)
	
	instance.position = Vector2(x_pos, y_pos)
	instance.setup(note_data, lane_width, fall_speed)
