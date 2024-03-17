class_name P_Fall_State extends Player_States


		#if self.vertical_speed > threshold_speed:
			#fall_damage = min(max_damage, math.ceil((self.vertical_speed - threshold_speed) * 0.5)
var fall_damage : float = 0.0
var fall_velocity : float = 0.0

func enter_state() -> void:
	# Override this method in each state script
	Global.dev_menu.update_property("StateMachine","Falling")
	fall_damage = 0.0
	fall_velocity = Entity.velocity.y

func exit_state() -> void:
	# Override this method in each state script
	pass
	
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
	if Entity.is_on_floor() and Entity.h_target_dir == Vector3.ZERO:
		return States.Idle
	elif Entity.h_target_dir != Vector3.ZERO and Entity.is_on_floor():
		return States.Walk
	return Key
