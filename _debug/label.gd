extends Label

var window_template: String = "Window: %.v"
var viewport_template: String = "Viewport: %.v"
var viewport_rect_template: String = "Viewport Rect: %.v"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    print("Window: ", get_window().size)
    print("Viewport: ", get_viewport().size)
    get_viewport().size_changed.connect(_on_vp_size_change)
    update_ui()

func _process(_delta) -> void:
    update_ui()

func update_ui() -> void:
    var win = get_window().size
    var vp = get_viewport().size
    var vp_rect = get_viewport().get_visible_rect().size
    self.text = "{0}\n{1}\n{2}".format([
        window_template % win,
        viewport_template % vp,
        viewport_rect_template % vp_rect
    ])

func _on_vp_size_change():
    print("viewport size changed")
