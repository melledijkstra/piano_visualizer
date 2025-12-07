class_name Song

var notes: Array[NoteData] = []

func _init(p_notes: Array[NoteData]) -> void:
  self.notes = p_notes

func duration() -> float:
  if notes.is_empty():
    return 0.0
  return notes[notes.size() - 1].end_time

func duration_formatted() -> String:
  var end_time = self.duration()

  var minutes = int(end_time / 60)
  var seconds = int(fmod(end_time, 60))
  return "%d:%02d" % [minutes, seconds]