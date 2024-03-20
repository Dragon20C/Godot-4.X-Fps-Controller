class_name P_Jump_State extends Player_States


func enter_state() -> void:
	# Override this method in each state script
	Global.dev_menu.update_property("StateMachine","Jumping")
	Entity.apply_jump()
	Global.footstep_node.on = false

func exit_state() -> void:
	# Override this method in each state script
	#Entity.camera.position.y = -0.2 # Add a landing effect when exiting jump state
	Global.footstep_node.on = true

func unhandled_state_input(event) -> void:
	# Override this method in each state script if needed
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Entity.rotate_look(event.relative * 0.001 * Entity.mouse_sensitivity)

func physics_update(delta) -> void:
	# Override this method in each state script if needed
	#Entity.handle_gravity(_delta)
	Entity.movement(delta)

func update(_delta) -> void:
	# Override this method in each state script if needed
	pass

func get_next_state() -> int:
	if Entity.h_target_dir == Vector3.ZERO and Entity.is_on_floor():
		return States.Idle
	elif Entity.is_on_floor():
		return States.Walk
	elif Entity.velocity.y <= 0:
		return States.Fall
	return Key
