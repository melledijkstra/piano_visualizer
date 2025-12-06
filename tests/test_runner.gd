extends Node

func _ready() -> void:
	run_tests()

func run_tests() -> void:
	var test_instance = load("res://tests/midi_test.gd").new()
	test_instance.run_all()
	get_tree().quit()
