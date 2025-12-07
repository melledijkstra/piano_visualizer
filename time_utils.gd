class_name TimeUtils

static func format_seconds(seconds_input: float) -> String:
	var negative = ""
	if seconds_input < 0.0:
		negative = "-"
	seconds_input = abs(seconds_input)
	var milliseconds = fmod(seconds_input, 1) * 100
	var seconds = fmod(seconds_input, 60)
	var minutes = seconds_input / 60
	return "%s%02d:%02d:%02d" % [negative, minutes, seconds, milliseconds]
