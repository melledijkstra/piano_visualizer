var midi_processor = preload("res://midi_preprocessor.gd").new()
var parser: MidiFileParser

func run_all():
	# test_normal_midi_flow()
	# test_clair_de_lune()
	test_cider_house()

func test_normal_midi_flow():
	# Load a test_normal_midi_flow MIDI file
	parser = MidiFileParser.load_file("res://input/chromatic_scales_test.mid")
	
	var song_data = midi_processor.preprocess(parser)
	
	# Basic assertions
	assert(song_data.size() > 0, "Song data should not be empty")
	
	for note in song_data:
		assert(note is NoteData, "Each item in song_data should be a NoteData object")
		assert(note.start_time >= 0.0, "Note start time should be non-negative")
		assert(note.duration > 0.0, "Note duration should be positive")
		assert(note.pitch >= 0 && note.pitch <= 127, "Note pitch should be between 0 and 127")
		assert(note.velocity >= 0 && note.velocity <= 127, "Note velocity should be between 0 and 127")
		# asserts specific to chromatic scales midi
		const chromatic_midi_notes = 132
		assert(song_data.size() == chromatic_midi_notes, "Chromatic scales midi should contain %d notes" % chromatic_midi_notes)
		assert(note.velocity > 0.78 and note.velocity < 0.79, "Note velocity should match the expected value")
		assert(note.duration >= 0.21 and note.duration <= 0.23, "Note duration should match the expected value")
	
	print("MIDI parsing test_normal_midi_flow passed!")

func test_clair_de_lune():
	# Load a test_normal_midi_flow MIDI file
	parser = MidiFileParser.load_file("res://input/clair_de_lune.mid")
	
	var song_data = midi_processor.preprocess(parser)

	assert(song_data.size() > 0, "Song data should not be empty")

func test_cider_house():
	parser = MidiFileParser.load_file("res://input/cider_house_rules.mid")
	
	var song_data = midi_processor.preprocess(parser)
	
	assert(song_data.size() > 0, "Song data should not be empty")
	
	var first_note = song_data.get(0)
	assert(first_note.key_name() == 'G4', 'First note should be G4')
	
	print("MIDI parsing test_cider_house passed!")
