class_name SongData

# private variables
var _midi_parser: MidiFileParser
var _midi_preprocessor = preload("res://midi_preprocessor.gd").new()

var file_path: String
var notes: Array[NoteData] = []
var is_parsed: bool = false

func _init(midi_file_path: String, should_parse: bool = false) -> void:
  self.file_path = midi_file_path
  if should_parse:
    parse()

func parse():
  if self.is_parsed:
    return
  self._midi_parser = MidiFileParser.load_file(self.file_path)
  self.notes = _midi_preprocessor.preprocess(self._midi_parser)
  is_parsed = true

func song_duration() -> float:
  if notes.is_empty():
    return 0.0
  return notes[notes.size() - 1].end_time

func song_duration_formatted() -> String:
  var end_time = self.song_duration()

  var minutes = int(end_time / 60)
  var seconds = int(fmod(end_time, 60))
  return "%d:%02d" % [minutes, seconds]