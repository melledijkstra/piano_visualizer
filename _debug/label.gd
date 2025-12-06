extends Label

var window_template: String = "Window: %.v"
var viewport_template: String = "Viewport: %.v"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Window: ", get_window().size)
	print("Viewport: ", get_viewport().size)
	update_ui()

func _process(_delta) -> void:
	update_ui()

func update_ui() -> void:
	var win = get_window().size
	var vp = get_viewport().size
	self.text = "{0}\n{1}".format([
		window_template % win,
		viewport_template % vp
	])
