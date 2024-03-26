extends Node

@export var player : Player
@export var target_position : Node3D
@export_subgroup("Step properties")
@export var CAMERA_SMOOTHING : float = 20.0
@export var MAX_STEP_UP := 0.5			# Maximum height in meters the player can step up.
@export var MAX_STEP_DOWN := -0.5		# Maximum height in meters the player can step down.
@export var distance_check : float = 0.14# Checks for how far we want to check for a stair up.
var vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical
var horizontal := Vector3(1, 0, 1)		# Shortcut for converting vectors to horizontal

func _process(delta):
	stair_step_down()
	stair_step_up()
	smooth_camera_jitter(delta)

func stair_step_down():
	if player.is_grounded:
		return

	# If we're falling from a step
	if player.velocity.y <= 0 and player.was_grounded:
		#_debug_stair_step_down("SSD_ENTER", null)													## DEBUG

		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = player.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			player.position.y += body_test_result.get_travel().y
			player.apply_floor_snap()
			player.is_grounded = true

func stair_step_up():
	if player.h_target_dir == Vector3.ZERO:
		return
		
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = player.global_transform				## Storing current global_transform for testing
	var distance = player.h_target_dir * distance_check		## Distance forward we want to check
	body_test_params.from = player.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	if !PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result):

		## If we don't collide, return
		return

	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = player.h_target_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (player.h_target_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())
		
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(player.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()
	var temp_floor_max_angle = player.floor_max_angle + deg_to_rad(20)
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > temp_floor_max_angle):
		return

	var global_pos = player.global_position
	#var step_up_dist = test_transform.origin.y - global_pos.y
	global_pos.y = test_transform.origin.y
	player.global_position = global_pos

func smooth_camera_jitter(delta):
	player.horizontal_node.global_position.x = target_position.global_position.x
	player.horizontal_node.global_position.y = lerpf(player.horizontal_node.global_position.y, target_position.global_position.y, CAMERA_SMOOTHING * delta)
	player.horizontal_node.global_position.z = target_position.global_position.z

	# Limit how far camera can lag behind its desired position
	player.horizontal_node.global_position.y = clampf(player.horizontal_node.global_position.y,
										-target_position.global_position.y - 1,
										target_position.global_position.y + 1)
