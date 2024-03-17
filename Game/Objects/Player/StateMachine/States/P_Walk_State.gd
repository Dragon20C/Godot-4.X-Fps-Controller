class_name P_Walk_State extends Player_States


func enter_state() -> void:
	# Override this method in each state script
	Global.dev_menu.update_property("StateMachine","Walking")

func exit_state() -> void:
	# Override this method in each state script
	pass

func unhandled_state_input(event) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Entity.rotate_look(event.relative * 0.001 * Entity.mouse_sensitivity)

func physics_update(delta) -> void:
	# Override this method in each state script if needed
	Entity.movement(delta)

func update(_delta) -> void:
	# Override this method in each state script if needed
	pass

func get_next_state() -> int:
	if Input.is_action_pressed("Jump") and Entity.is_on_floor():
		return States.Jump
		
	if Entity.h_target_dir == Vector3.ZERO:
		return States.Idle
	return Key