extends Node

@export_subgroup("Misc")
@export var player : Player
@export var weapon_container : Node3D # The node that holds your weapon

@export_subgroup("Procedural Kickback")
@export var weapon_kickback_rot_x : Vector2 = Vector2(1,1)
@export var weapon_kickback_rot_y : Vector2 = Vector2(-0.1,0.1)
@export var weapon_kickback_rot_z : Vector2 = Vector2(0,1)
@export var kickback_return_speed : float = 8.0
@export var not_shooting_return_speed : float = 3.0
@export var kickback_speed : float = 12.0

var kickback_compensation : float = 0.0
var kickback_start_position : Vector3 = Vector3.ZERO
var kickback_end_position : Vector3 = Vector3.ZERO
var kickback_start_rotation : Vector3 = Vector3.ZERO
var kickback_end_rotation : Vector3 = Vector3.ZERO

var kickback_pos : Vector3
var kickback_rot : Vector3

@export_subgroup("Procedural Sway")
var mouse_motion : Vector2
@export var sway_amount : float = 0.005
@export var max_pos_sway_amount : Vector3 = Vector3(0.001,0.0,0.0)
@export var max_rot_sway_amount : Vector3 = Vector3(0.01,0.1,0.1)
@export var sway_pos_speed : float = 5.0
@export var sway_rot_speed : float = 8.0
@export var sway_return_speed : float = 18.0

var sway_rot : Vector3 = Vector3.ZERO
var sway_pos : Vector3 = Vector3.ZERO

@export_subgroup("Procedural Bob")
@export var bob_smooth : float = 12.0
@export var bob_return_speed : float = 10.0
@export var frequency : float = 1.0
@export var amplitude : float = 0.01
@export var bobbing_speed :float = 1.0
var motion : float =  0.0
var bob_pos : Vector3

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = -event.relative * sway_amount

func _process(delta):
	handle_bob(delta)
	handle_sway(delta)
	handle_kickback(delta)
	handle_motion(delta)

# Handles adding all the motions together.
func handle_motion(delta : float) -> void:
	weapon_container.position = kickback_pos + sway_pos + bob_pos
	weapon_container.rotation = kickback_rot + sway_rot

# Handles the kickback when apply positional and rotational functions are called.
func handle_kickback(delta : float) -> void:
	
	if kickback_pos == Vector3.ZERO and kickback_end_position == Vector3.ZERO:
		return
	
	# if kickback end pos is vector3.zero we use return speed
	var speed : float = kickback_return_speed if kickback_end_position == Vector3.ZERO else kickback_speed
	
	
	if not Input.is_action_pressed("Action_Left_Click") and kickback_end_position == Vector3.ZERO:
		speed = not_shooting_return_speed
	
	kickback_compensation += speed * delta
	kickback_pos = lerp(kickback_start_position,kickback_end_position,kickback_compensation)
	kickback_rot = lerp(kickback_start_rotation,kickback_end_rotation,kickback_compensation)
	
	if kickback_compensation > 1.0:
		kickback_compensation = 0.0
		kickback_start_position = kickback_pos
		kickback_start_rotation = kickback_rot
		kickback_end_position = Vector3.ZERO
		kickback_end_rotation = Vector3.ZERO

# Call these functions in your own weapon manager when shooting
func apply_kickback_pos() -> void:
	kickback_end_position = Vector3(0,0,deg_to_rad(1.8))

func apply_kickback_rot() -> void:
	kickback_end_rotation = Vector3(
		randf_range(deg_to_rad(weapon_kickback_rot_x.x),deg_to_rad(weapon_kickback_rot_x.y)),
		randf_range(deg_to_rad(weapon_kickback_rot_y.x),deg_to_rad(weapon_kickback_rot_y.y)),
		randf_range(deg_to_rad(weapon_kickback_rot_z.x),deg_to_rad(weapon_kickback_rot_z.y))
	)

# Handle Sway of the weapon when mouse movement is detected
func handle_sway(delta : float) -> void:
	mouse_motion = lerp(mouse_motion,Vector2.ZERO,sway_return_speed * delta)
	
	var inital_sway_pos = Vector3(mouse_motion.x,mouse_motion.y,0)
	var inital_sway_rot = Vector3(mouse_motion.y,mouse_motion.x,mouse_motion.x)
	
	inital_sway_pos = inital_sway_pos.clamp(-max_pos_sway_amount,max_pos_sway_amount)
	inital_sway_rot = inital_sway_rot.clamp(-max_rot_sway_amount,max_rot_sway_amount)
	
	sway_pos = sway_pos.lerp(inital_sway_pos, sway_pos_speed * delta)
	sway_rot = sway_rot.lerp(inital_sway_rot, sway_rot_speed * delta)

# Handle bobbing fo the weapon
func handle_bob(delta : float) -> void:
	
	var check_floor : int = player.was_grounded as int
	
	var jump_motion : float = player.velocity.y
	jump_motion = clampf(jump_motion,-2,2) # Limit the motion of the jump
	
	# Apply some value to motion so we can move the weapon
	motion += player.velocity.length() * check_floor * bobbing_speed * delta
	
	
	var pos : Vector3 = Vector3.ZERO
	pos.y = -abs(sin(motion * frequency * check_floor) * amplitude) - (jump_motion * 0.01) 
	pos.x = (sin(motion * frequency) * amplitude)
	
	# Temp fix for having the crosshairs align to the center
	if Input.is_action_pressed("Action_Right_Click"):
		pos = Vector3.ZERO
	
	bob_pos = bob_pos.lerp(pos,bob_smooth * delta)

