class_name Player extends CharacterBody3D

@onready var mesh : Node3D = get_node("Player_Mesh")
@onready var animation_tree : AnimationTree = mesh.get_node("AnimationTree")
@onready var target_position : Node3D = get_node("Target_position")
@export var horizontal_node : Node3D
@export var vertical_node : Node3D
@export var camera : Camera3D

@export_subgroup("Head bob Properties")
var bob_rate : float = 0.0
@export var frequency : float = 1.2
@export var amplitude : float = 0.08
@export var camera_smooth : float = 18.0
@export var camera_return_speed : float = 4.0
@export var camera_stab : Node3D
@export var stab_target : Marker3D

@export_subgroup("Player Properties")
@export var CAMERA_SMOOTHING : float = 20.0
@export var mouse_sensitivity := 1.5
@export var fall_speed_threshold : float = 12.5
@export var max_fall_damage : float = 25.0



@export_subgroup("Properties")
@export var stop_speed := 4.0
@export var crouch_speed : float = 4.0
@export var sprint_speed : float = 7.5
@export var walk_speed : float = 5.2
var move_speed : float = walk_speed

@export var gravity := 18.0
@export var max_fall_speed := 20.0
@export var jump_height := 1.0

@export var accel_ground := 10.0
@export var accel_air := 1.0

@export var friction_ground := 6.0

var h_target_dir : Vector3

@export_subgroup("Step properties")
@export var MAX_STEP_UP := 0.5			# Maximum height in meters the player can step up.
@export var MAX_STEP_DOWN := -0.5		# Maximum height in meters the player can step down.
@export var distance_check : float = 0.14# Checks for how far we want to check for a stair up.
var is_grounded := true					# If player is grounded this frame
var was_grounded := true				# If player was grounded last frame
var vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical
var horizontal := Vector3(1, 0, 1)		# Shortcut for converting vectors to horizontal

@export_subgroup("MISC")
@export var weapon_manager : Node
var look_dir : Vector3

func _ready():
	if not is_multiplayer_authority(): return
	mesh.visible = false
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func rotate_look(amount : Vector2) -> void:
	if not is_multiplayer_authority(): return
	look_dir.y -= amount.x
	look_dir.x -= amount.y
	
	weapon_manager.recoil_compensation(amount)

func _physics_process(delta):
	head_bobbing(delta)
	#camera_stabilisation()
	apply_camera_motion()
	handle_mouse_focus()
	if Global.dev_menu != null:
		Global.dev_menu.update_property("Velocity",str("%.2f" % velocity.length()))

# In this function I am applying the camera rotation and also recoil rotation
func apply_camera_motion() -> void:
	look_dir.x = clampf(look_dir.x,-PI * 0.5,PI * 0.5)
	rotation.y = look_dir.y + weapon_manager.recoil.y
	horizontal_node.rotation.y = look_dir.y + weapon_manager.recoil.y
	vertical_node.rotation.x = look_dir.x + weapon_manager.recoil.x

func handle_mouse_focus() -> void:
	if not is_multiplayer_authority(): return
	
	#if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().quit()
		#if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#else:
			#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_move_direction() -> Vector3:
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func apply_jump() -> void:
	velocity.y = sqrt(2 * jump_height * abs(gravity))

func movement(delta : float) -> void:
	#var was_on_floor : bool = is_on_floor()
	h_target_dir = get_move_direction()
	
	was_grounded = is_grounded
	
	if is_on_floor():
		is_grounded = true
		apply_friction(delta)
		accelerate(delta, h_target_dir, move_speed, accel_ground)
	else:
		is_grounded = false
		# hack: only add gravity not on ground, to prevent sliding on slopes 
		# This works because move_and_slide_with_snap warps the player to the ground in other cases
		velocity.y = max(-max_fall_speed, velocity.y - gravity * delta)
		accelerate(delta, h_target_dir, move_speed, accel_air)
	
	move_and_slide()

func accelerate(delta : float, p_target_dir : Vector3, p_target_speed : float, p_accel : float):
	var current_speed : float = velocity.dot(p_target_dir)
	var add_speed : float = p_target_speed - current_speed
	if add_speed > 0:
		var accel_speed : float = min(add_speed, p_accel * delta * p_target_speed)
		velocity += p_target_dir * accel_speed

func apply_friction(delta : float):
	
	var speed : float = velocity.length()
	if is_zero_approx(speed):
		velocity = Vector3.ZERO
		return
	
	var drop : float = 0.0
	var control : float = max(speed, stop_speed)
	
	# ground friction
	if is_on_floor():
		drop += control * friction_ground * delta
	
	var new_speed : float = max(0.0, speed - drop)
	new_speed /= speed
	
	velocity *= new_speed

func head_bobbing(delta : float) -> void:
	if velocity.length() > 0 and was_grounded:
		bob_rate += delta * velocity.length()
		var motion = bob_motion()
		
		camera.transform.origin = lerp(camera.transform.origin,motion,camera_smooth * delta)
		
		#if motion.y < -amplitude + 0.01 and not stepped:
			#stepped = true
			#play_step_sound()
		#elif motion.y > -0.01:
			#stepped = false
	elif velocity.length() == 0 or not was_grounded:
		restart_camera(delta)

func bob_motion() -> Vector3:
	var pos = Vector3.ZERO
	pos.y = -abs(sin(bob_rate * frequency) * amplitude)
	pos.x = sin(bob_rate * frequency) * amplitude
	return pos
	
func restart_camera(delta):
	if camera.transform.origin == Vector3.ZERO: return
	
	camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO,camera_return_speed * delta)
	bob_rate = 0.0

func camera_stabilisation() -> void:
	camera.look_at(stab_target.global_position)
