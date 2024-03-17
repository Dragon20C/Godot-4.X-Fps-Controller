# State.gd
class_name Player_States extends Node

var States : Dictionary
var Key : int
var Entity : Player

func enter_state() -> void:
	# Override this method in each state script
	pass

func exit_state() -> void:
	# Override this method in each state script
	pass

func unhandled_state_input(_event) -> void:
	# Override this method in each state script if needed
	pass

func physics_update(_delta) -> void:
	# Override this method in each state script if needed
	pass

func update(_delta) -> void:
	# Override this method in each state script if needed
	pass

func get_next_state() -> int:
	return Key
