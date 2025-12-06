class_name MidiPreprocessor extends Node

const DEBUG = false

func debug(...args):
	if (DEBUG): print(args)

# Main function to preprocess the raw MIDI data into a list of NoteData
func preprocess(midi_parser: MidiFileParser) -> Array[NoteData]:
	debug("Starting MIDI preprocessing...")
	var all_events = []

	# 1. Flatten all tracks into a single timeline of events
	debug("Found %d tracks" % midi_parser.tracks.size())
	for i in range(midi_parser.tracks.size()):
		var track = midi_parser.tracks[i]
		var current_tick = 0
		for event in track.events:
			current_tick += event.delta_ticks
			all_events.append({"tick": current_tick, "event": event})
	
	# 2. Sort all events chronologically by their absolute tick
	all_events.sort_custom(func(a, b): return a.tick < b.tick)
	debug("Total (sorted) events: %d" % all_events.size())

	# 3. Iterate through the sorted timeline to calculate seconds and extract notes
	var final_notes: Array[NoteData] = []
	var active_notes = {}  # Stores notes that are currently "On"

	var current_time_seconds = 0.0
	var last_tick = 0

	# Get ticks per quarter note from the MIDI header
	var ticks_per_quarter = float(midi_parser.header.time_division)
	debug("Ticks per quarter: %d" % ticks_per_quarter)

	# Default tempo is 120 BPM if not specified
	var microseconds_per_quarter = 500000.0

	for item in all_events:
		var abs_tick = item.tick
		var event = item.event

		# Calculate time passed since the last event
		var delta_ticks = abs_tick - last_tick
		if delta_ticks > 0:
			var seconds_per_tick = (microseconds_per_quarter / ticks_per_quarter) / 1000000.0
			current_time_seconds += delta_ticks * seconds_per_tick
		
		last_tick = abs_tick

		# --- Handle Tempo Changes ---
		if event.event_type == MidiFileParser.Event.EventType.META \
		and event.type == MidiFileParser.Meta.Type.SET_TEMPO:
			microseconds_per_quarter = float(event.value)
			debug("  [%d] Tempo change: %f us per quarter note" % [abs_tick, microseconds_per_quarter])

		# --- Handle Note Events ---
		elif event.event_type == MidiFileParser.Event.EventType.MIDI:
			var note_idx: int = event.param1 # MIDI Note Number (0-127)
			var velocity: float = event.velocity # MIDI Note Velocity (0-1)

			# Note On event (including velocity 0 as Note Off)
			if event.status == MidiFileParser.Midi.Status.NOTE_ON:
				if velocity > 0:
					# If this note is already on, finish the old one first
					if active_notes.has(note_idx):
						debug("  WARN: Note %d was already on. Finishing it." % note_idx)
						_finish_note(active_notes, note_idx, current_time_seconds, final_notes)
					
					# Start a new note
					debug("  [%d] Note ON: %d (vel: %.2f) at %.4fs" % [abs_tick, note_idx, velocity, current_time_seconds])
					active_notes[note_idx] = {
						"start": current_time_seconds,
						"vel": velocity
					}
				else: # Velocity is 0, which means Note Off
					if active_notes.has(note_idx):
						debug("  [%d] Note OFF (from NoteOn w/ vel 0): %d at %.4fs" % [abs_tick, note_idx, current_time_seconds])
						_finish_note(active_notes, note_idx, current_time_seconds, final_notes)

			# Note Off event
			elif event.status == MidiFileParser.Midi.Status.NOTE_OFF:
				if active_notes.has(note_idx):
					debug("  [%d] Note OFF: %d at %.4fs" % [abs_tick, note_idx, current_time_seconds])
					_finish_note(active_notes, note_idx, current_time_seconds, final_notes)

	debug("Finished processing. Total notes parsed: %d" % final_notes.size())
	return final_notes


# Helper to finalize a note and add it to the list
func _finish_note(active_notes, note_idx, current_time, list):
	var data = active_notes.get(note_idx)
	var new_note = NoteData.new()
	new_note.pitch = note_idx
	new_note.start_time = data.start
	new_note.end_time = current_time
	# Ensure duration is never negative, which can happen with overlapping notes
	new_note.duration = max(0, current_time - data.start)
	new_note.velocity = data.vel

	# Avoid adding zero-duration notes, which can occur in some MIDI files
	if new_note.duration > 0.001:
		debug("    -> Finalized note %d (start: %.4f, end: %.4f, dur: %.4f)" % [note_idx, new_note.start_time, new_note.end_time, new_note.duration])
		list.append(new_note)
	else:
		debug("    -> Discarding zero-duration note %d" % note_idx)

	active_notes.erase(note_idx)
