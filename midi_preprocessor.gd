class_name MidiPreprocessor extends Node

# Main function to parse the raw MIDI data into a list of NoteData
func parse(midi_parser: MidiFileParser) -> Array[NoteData]:
	var all_events = []
	
	# 1. Flatten all tracks into a single timeline sorted by absolute Ticks
	for track in midi_parser.tracks:
		var current_tick = 0
		for event in track.events:
			current_tick += event.delta_ticks
			# We bundle the event with its absolute tick so we can sort them later
			all_events.append({
				"tick": current_tick,
				"event": event
			})
	
	# Sort events by tick (chronological order)
	all_events.sort_custom(func(a, b): return a.tick < b.tick)
	
	# 2. Iterate through time to calculate seconds and extract notes
	var final_notes: Array[NoteData] = []
	var active_notes = {} # Stores notes that are currently "On" (waiting for an "Off")
	
	var current_time_seconds = 0.0
	var last_tick = 0
	
	# Get ticks per quarter note from the MIDI header.
	var ticks_per_quarter = 480 # Default if not specified
	if midi_parser.header and "time_division" in midi_parser.header:
		ticks_per_quarter = midi_parser.header.time_division
	print('ticks per quarter: ', ticks_per_quarter)
		
	# Tempo is tracked in microseconds per quarter note. Default is 120 BPM.
	var microseconds_per_quarter = 500000.0

	for item in all_events:
		var abs_tick = item.tick
		var event = item.event
		
		# Calculate how much time passed since the last event in seconds.
		var delta_ticks = abs_tick - last_tick
		if delta_ticks > 0:
			var seconds_per_tick = (microseconds_per_quarter / ticks_per_quarter) / 1000000.0
			current_time_seconds += delta_ticks * seconds_per_tick
			last_tick = abs_tick
			
		# --- Handle Tempo Changes ---
		if event.event_type == MidiFileParser.Event.EventType.META and event.type == MidiFileParser.Meta.Type.SET_TEMPO:
			# The 'value' from the parser for a SET_TEMPO event is the new microseconds per quarter note.
			microseconds_per_quarter = float(event.value)
			
		# --- Handle Notes ---
		if event.event_type == MidiFileParser.Event.EventType.MIDI:
			var note_idx: int = event.param1 # MIDI Note Number (0-127)
			var velocity: float = event.velocity # MIDI Note Velocity (0-1)
			
			# Note On (Velocity > 0)
			# The parser has a bug where it reuses the same event object, so we must check velocity.
			if event.velocity > 0 and event.status == MidiFileParser.Midi.Status.NOTE_ON:
				# If we are already playing this note, cut it off (rare edge case)
				if active_notes.has(note_idx):
					_finish_note(active_notes, note_idx, current_time_seconds, final_notes)
				
				# Start a new note
				active_notes[note_idx] = {
					"start": current_time_seconds,
					"vel": float(velocity)
				}
				
			# Note Off (status is NOTE_OFF or velocity is 0)
			elif event.status == MidiFileParser.Midi.Status.NOTE_OFF or (event.status == MidiFileParser.Midi.Status.NOTE_ON and event.velocity == 0):
				if active_notes.has(note_idx):
					_finish_note(active_notes, note_idx, current_time_seconds, final_notes)
					
	return final_notes

# Helper to finalize a note and add it to the list
func _finish_note(active_notes, note_idx, current_time, list):
	var data = active_notes.get(note_idx)
	var new_note = NoteData.new()
	new_note.pitch = note_idx
	new_note.start_time = data.start
	new_note.end_time = current_time
	new_note.duration = current_time - data.start
	new_note.velocity = data.vel
	
	list.append(new_note)
	active_notes.erase(note_idx)
