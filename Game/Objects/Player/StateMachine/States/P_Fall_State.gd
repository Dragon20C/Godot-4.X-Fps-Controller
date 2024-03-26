class_name P_Fall_State extends Player_States


var fall_damage : float = 0.0
var fall_velocity : float = 0.0

func enter_state() -> void:
	# Override this method in each state script
	Global.dev_menu.update_property("StateMachine","Falling")
	fall_damage = 0.0
	fall_velocity = Entity.velocity.y
	Global.footstep_node.on = false

func exit_state() -> void:
	# Override this method in each state script
	Global.footstep_node.on = true
	
func unhandled_state_input(event) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Entity.rotate_look(event.relative * 0.001 * Entity.mouse_sensitivity)

func physics_update(delta) -> void:
	# Override this method in each state script if needed
	Entity.movement(delta)
	
	if Entity.velocity.y < -Entity.fall_speed_threshold:
		fall_damage = min(Entity.max_fall_damage,ceilf(Entity.velocity.y - Entity.fall_speed_threshold))
		
func update(_delta) -> void:
	# Override this method in each state script if needed
	pass

func get_next_state() -> int:
	if Entity.was_grounded and Entity.h_target_dir == Vector3.ZERO:
		return States.Idle
	if Entity.h_target_dir != Vector3.ZERO and Entity.was_grounded and Input.is_action_pressed("Sprint"):
		return States.Sprint
	if Entity.h_target_dir != Vector3.ZERO and Entity.was_grounded:
		return States.Walk
	return Key
