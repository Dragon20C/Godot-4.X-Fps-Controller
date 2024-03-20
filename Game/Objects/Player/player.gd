class_name Player extends CharacterBody3D

@onready var mesh : Node3D = get_node("Player_Mesh")
@onready var animation_tree : AnimationTree = mesh.get_node("AnimationTree")
@onready var head_container : Node3D = get_node("HeadContainer")
@onready var horizontal_node : Node3D = get_node("HeadContainer/Horizontal")
@onready var vertical_node : Node3D = get_node("HeadContainer/Horizontal/Vertical")
@onready var camera : Camera3D = get_node("HeadContainer/Horizontal/Vertical/Camera3D")

@export_subgroup("Player Properties")
@export var CAMERA_SMOOTHING : float = 20.0
@export var mouse_sensitivity := 1.5
@export var fall_speed_threshold : float = 12.5
@export var max_fall_damage : float = 25.0



@export_subgroup("Properties")
@export var stop_speed := 4.0
@export var move_speed := 7.5

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
	#vertical_node.rotation.x = clamp(vertical_node.rotation.x - amount.y, -PI * 0.5, PI * 0.5)
	
	weapon_manager.recoil_compensation(amount)

func _physics_process(delta):	
	apply_camera_motion()
	handle_mouse()
	smooth_camera_jitter(delta)
	Global.dev_menu.update_property("Velocity",str("%.2f" % velocity.length()))

# In this function I am applying the camera rotation and also recoil rotation
func apply_camera_motion() -> void:
	look_dir.x = clampf(look_dir.x,-PI * 0.5,PI * 0.5)
	rotation.y = look_dir.y + weapon_manager.recoil.y
	horizontal_node.rotation.y = look_dir.y + weapon_manager.recoil.y
	vertical_node.rotation.x = look_dir.x + weapon_manager.recoil.x

func handle_mouse() -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
	
	stair_step_up()
	move_and_slide()
	stair_step_down()


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

func stair_step_down():
	if is_grounded:
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:
		#_debug_stair_step_down("SSD_ENTER", null)													## DEBUG

		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true

func stair_step_up():
	if h_target_dir == Vector3.ZERO:
		return
		
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = h_target_dir * distance_check		## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):

		## If we don't collide, return
		return

	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = h_target_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (h_target_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())
		
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	var temp_floor_max_angle = floor_max_angle + deg_to_rad(20)
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > temp_floor_max_angle):
		return

	var global_pos = global_position
	#var step_up_dist = test_transform.origin.y - global_pos.y
	global_pos.y = test_transform.origin.y
	global_position = global_pos

func smooth_camera_jitter(delta):
	horizontal_node.global_position.x = head_container.global_position.x
	horizontal_node.global_position.y = lerpf(horizontal_node.global_position.y, head_container.global_position.y, CAMERA_SMOOTHING * delta)
	horizontal_node.global_position.z = head_container.global_position.z

	# Limit how far camera can lag behind its desired position
	horizontal_node.global_position.y = clampf(horizontal_node.global_position.y,
										-head_container.global_position.y - 1,
										head_container.global_position.y + 1)

