# Rename class name to the object this state machine is used for.
class_name Temp_States extends Node

var States : Dictionary
var Key : int
var Entity : Player # replace this with your object if it has a class if not just make it the same node

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
