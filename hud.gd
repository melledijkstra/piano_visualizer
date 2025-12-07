extends CanvasLayer

@onready var simulation_info: Label = %SimulationInfo
@onready var song_info: Label = %SongInfo
@onready var speed_slider: HSlider = %SpeedSlider
@onready var timeline_slider: HSlider = %TimelineSlider

# -- State --
var song: Song = null
var current_time: float

func _ready() -> void:
  if song_info.is_node_ready() and song:
    update_song_info()

func _on_song_loaded(song_data: Song) -> void:
  self.song = song_data
  update_song_info()

func _on_time_updated(_current_time: float) -> void:
  current_time = _current_time
  update_simulation_info()

func update_simulation_info():
  simulation_info.text = "Speed: {speed}\nTime: {time}".format({
    "speed": speed_slider.value,
    "time": TimeUtils.format_seconds(current_time)
  })

func update_song_info():
  if not song_info: return
  song_info.text = "Notes: {notes}\nTotal song time: {song_duration}".format({
    "notes": str(song.notes.size()),
    "song_duration": song.duration_formatted()
  })
