class_name MidiPreprocessor

const DEBUG = false

static func debug(...args):
	if (DEBUG): print.callv(args)

static var _final_notes: Array[NoteData] = []
static var _active_notes = {}  ## Stores notes that are currently "On"

# Main function to preprocess the raw MIDI data into a list of NoteData
static func preprocess(midi_parser: MidiFileParser) -> Array[NoteData]:
	debug("Starting MIDI preprocessing...")
	var all_events: Array[Dictionary] = []

	# - Flatten all tracks into a single timeline of events
	debug("Found %d tracks" % midi_parser.tracks.size())
	for i in range(midi_parser.tracks.size()):
		var track = midi_parser.tracks[i]
		var current_tick: int = 0
		for event in track.events:
			current_tick += event.delta_ticks
			all_events.append({"tick": current_tick, "event": event})
	
	# - Sort all events chronologically by their absolute tick
	all_events.sort_custom(func(a, b): return a.tick < b.tick)
	debug("Total (sorted) events: %d" % all_events.size())

	var current_time_seconds = 0.0
	var last_tick = 0

	# Get ticks per quarter note from the MIDI header
	var ticks_per_quarter = float(midi_parser.header.time_division)
	debug("Ticks per quarter: %d" % ticks_per_quarter)

	# Default tempo is 120 BPM if not specified
	var microseconds_per_quarter = 500000.0

	# - Iterate through the sorted timeline to calculate seconds and extract notes
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
			debug("  [%d] Tempo change: %f us per quarter note (bpm: %.2f)" % [abs_tick, microseconds_per_quarter, _to_bpm(microseconds_per_quarter)])

		# --- Handle Note Events ---
		elif event.event_type == MidiFileParser.Event.EventType.MIDI:
			var note_idx: int = event.param1 # MIDI Note Number (0-127)
			var velocity: float = event.velocity # MIDI Note Velocity (0-1)

			# Note On event (including velocity 0 as Note Off)
			if event.status == MidiFileParser.Midi.Status.NOTE_ON:
				if velocity > 0:
					# If this note is already on, finish the old one first
					if _active_notes.has(note_idx):
						debug("  WARN: Note %d was already on. Finishing it." % note_idx)
						_finish_note(note_idx, current_time_seconds)
					
					# Start a new note
					debug("  [%d] Note ON: %d (vel: %.2f) at %.4fs" % [abs_tick, note_idx, velocity, current_time_seconds])
					_active_notes[note_idx] = {
						"start": current_time_seconds,
						"vel": velocity
					}
				else: # Velocity is 0, which means Note Off
					if _active_notes.has(note_idx):
						debug("  [%d] Note OFF (from NoteOn w/ vel 0): %d at %.4fs" % [abs_tick, note_idx, current_time_seconds])
						_finish_note(note_idx, current_time_seconds)

			# Note Off event
			elif event.status == MidiFileParser.Midi.Status.NOTE_OFF:
				if _active_notes.has(note_idx):
					debug("  [%d] Note OFF: %d at %.4fs" % [abs_tick, note_idx, current_time_seconds])
					_finish_note(note_idx, current_time_seconds)

	debug("Finished processing. Total notes parsed: %d" % _final_notes.size())
	return _final_notes

# Helper to finalize a note and add it to the list
static func _finish_note(note_idx, current_time):
	var data = _active_notes.get(note_idx)
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
		_final_notes.append(new_note)
	else:
		debug("    -> Discarding zero-duration note %d" % note_idx)

	_active_notes.erase(note_idx)


static func _to_bpm(microseconds_per_quarter: float) -> float:
	return 60000000.0 / microseconds_per_quarter