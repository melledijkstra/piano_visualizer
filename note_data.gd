## A simple class to hold the data for a single visual note
class_name NoteData

## The pitch of this note | 0 - 127 range | A0 (21) to C8 (108)
var pitch: int
## The start time of this note in seconds
var start_time: float
## The end time of this note in seconds
var end_time: float
## The duration of this note in seconds
var duration: float
## The velocity of this note | 0-1 range
var velocity: float

func key_name() -> String:
	var octave: int = self.get_octave()
	var key_index = self.pitch % Globals.NOTES_IN_OCTAVE
	return "%s%d" % [Globals.NOTE_NAMES[key_index], octave]

func get_octave() -> int:
	return floor((self.pitch - Globals.NOTES_IN_OCTAVE) / Globals.NOTES_IN_OCTAVE)

func _to_string() -> String:
	return "NoteData(pitch=%d, key=%s, start_time=%.2f, end_time=%.2f, duration=%.2f, velocity=%.2f)" % [
		pitch, self.key_name(), start_time, end_time, duration, velocity
	]
