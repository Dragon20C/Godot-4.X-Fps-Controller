class_name P_Sprint_State extends Player_States



func enter_state() -> void:
	# Override this method in each state script
	Global.dev_menu.update_property("StateMachine","Sprinting")
	Entity.move_speed = Entity.sprint_speed

func exit_state() -> void:
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
	
	if Input.is_action_pressed("Jump") and Entity.was_grounded:
		return States.Jump
	
	if Entity.was_grounded and Entity.h_target_dir == Vector3.ZERO:
		return States.Idle
	
	if Input.is_action_just_released("Sprint") and not Entity.was_grounded:
		return States.Fall
	
	if Input.is_action_just_released("Sprint") and Entity.was_grounded:
		return States.Walk
		
	if Input.is_action_just_pressed("Jump") and Entity.was_grounded:
		return States.Jump
		
	return Key
