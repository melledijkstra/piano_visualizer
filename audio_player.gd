extends AudioStreamPlayer2D

var time: float = 0.0

func _on_midi_sequencer_time_updated(current_time: float) -> void:
    time = current_time
    if not self.playing and current_time >= 0.0:
        self.play(time)

func _on_play_pause_btn_toggled(toggled_on: bool) -> void:
    if toggled_on:
        self.play(time)
    else:
        self.stop()
