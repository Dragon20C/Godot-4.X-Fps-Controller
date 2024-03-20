extends Node

@export var muzzle_flash : MeshInstance3D
@export var container_node : Node3D
@export var cooldown : Timer
@export var raycast : RayCast3D
@export var gun_shot_sfx : AudioStreamPlayer
@export var camera : Camera3D
@onready var bullet_hole_decal : PackedScene = preload("res://Game/Objects/Bullet hole decal/bullet_hole.tscn")

@export var weapon_motion : Node

@export var container_offset_node : Node3D
@export var aim_speed : float = 18.0
var aim_pos : Vector3 = Vector3(0.0,-0.101,-0.275)
var hip_pos : Vector3 = Vector3(0.095,-0.1,-0.365)
var shooting : bool = false
var aiming : bool = false


@export_subgroup("Weapon Stats")
@export var fire_rate : float = 0.08

@export_subgroup("Recoil Parameter")
@export var recoil_pattern := [
	Vector3(0.1 , -0.04, 0),
	Vector3(0.11 , -0.05, 0),
	Vector3(0.12 , 0.04, 0),
	Vector3(0.12 , 0.03, 0),
	Vector3(0.11 , -0.08, 0),
	Vector3(0.11 , 0.1, 0),
	Vector3(0.11 , 0.07, 0),
	Vector3(0.11 , -0.04, 0),
	Vector3(0.12 , -0.02, 0),
	Vector3(0.13 , 0.05, 0),
]


var target_recoil = Vector3.ZERO
var recoil = Vector3.ZERO
var recoil_speed: float = 5
var recoil_return_speed: float = 0.5
var shot_count : int = 0

@export var player : Player
func _ready():
	cooldown.wait_time = fire_rate

func _process(delta):
	
	handle_recoil(delta)
	
	if Input.is_action_pressed("Action_Left_Click") and cooldown.is_stopped():
		# Applying procedural animations
		shooting = true
		shot_count += 1
		apply_recoil()
		
		# Visuals
		weapon_motion.apply_kickback_pos()
		weapon_motion.apply_kickback_rot()
		cooldown.start()
		gun_shot_sfx.play()
		
		# Raycast detecting
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var object = raycast.get_collider()
			var point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			handle_bullet_decal(point,normal)
	
	if Input.is_action_just_released("Action_Left_Click") and shooting:
		shot_count = 0
		shooting = false
	
	if Input.is_action_pressed("Action_Right_Click"):
		aiming = true
	else:
		aiming = false
		
	if aiming:
		container_offset_node.position = container_offset_node.position.lerp(aim_pos,aim_speed * delta)
	else:
		container_offset_node.position = container_offset_node.position.lerp(hip_pos,aim_speed * delta)
	
func apply_recoil() -> void:
	var index = min(shot_count,recoil_pattern.size() - 1)
	target_recoil += recoil_pattern[index]

func handle_recoil(delta : float) -> void:
	if target_recoil == Vector3.ZERO and recoil == Vector3.ZERO: return
	
	target_recoil.x -= min(sign(target_recoil.x) * delta * recoil_return_speed, abs(target_recoil.x))
	target_recoil.y -= min(sign(target_recoil.y) * delta * recoil_return_speed, abs(target_recoil.y))
	target_recoil.z -= min(sign(target_recoil.z) * delta * recoil_return_speed, abs(target_recoil.z))
	#target_recoil = lerp(target_recoil,Vector3.ZERO,recoil_return_speed * delta)
	recoil = lerp(recoil,target_recoil,recoil_speed * delta)
	
func recoil_compensation(mouse_delta: Vector2):
	# we don't need to do any of this if recoil is zero
	if target_recoil == Vector3.ZERO and recoil == Vector3.ZERO:
		return
	
	# x axis
	# you can read this as "if we're componsating for recoil in this direction"
	if target_recoil.x < 0 && mouse_delta.y < 0:
		# if we go past 0, we set recoil to 0
		# and add the existing target_recoil to look_rotation
		if target_recoil.x - mouse_delta.y > 0:
			player.look_dir.x += target_recoil.x
			target_recoil.x = 0
		# otherwise, we substract mouse delta from target_recoil 
		# and add mouse delta to look_rotation
		else:
			player.look_dir.x += mouse_delta.y
			target_recoil.x -= mouse_delta.y
	
	elif target_recoil.x > 0 && mouse_delta.y > 0:
		if target_recoil.x - mouse_delta.y < 0:
			player.look_dir.x += target_recoil.y
			target_recoil.x = 0
		else:
			player.look_dir.x += mouse_delta.y
			target_recoil.x -= mouse_delta.y
	
	# do the same for the smooth recoil
	# might not be necesarry
	if recoil.x < 0 && mouse_delta.y < 0:
		if recoil.x - mouse_delta.y > 0:
			recoil.x = 0
		else:
			recoil.x -= mouse_delta.y
	
	elif recoil.x > 0 && mouse_delta.y > 0:
		if recoil.x - mouse_delta.y < 0:
			recoil.x = 0
		else:
			recoil.x -= mouse_delta.y
	
	# y axis
	if target_recoil.y < 0 && mouse_delta.x < 0:
		if target_recoil.y - mouse_delta.y > 0:
			player.look_dir.y += target_recoil.y
			target_recoil.y = 0
		else:
			player.look_dir.y += mouse_delta.x
			target_recoil.y -= mouse_delta.x
	
	elif target_recoil.y > 0 && mouse_delta.x > 0:
		if target_recoil.y - mouse_delta.x < 0:
			player.look_dir.y += target_recoil.y
			target_recoil.y = 0
		else:
			player.look_dir.y += mouse_delta.x
			target_recoil.y -= mouse_delta.x
	
	if recoil.y < 0 && mouse_delta.x < 0:
		if recoil.y - mouse_delta.x > 0:
			recoil.y = 0
		else:
			recoil.y -= mouse_delta.x
	
	elif recoil.y > 0 && mouse_delta.x > 0:
		if recoil.y - mouse_delta.x < 0:
			recoil.y = 0
		else:
			recoil.y -= mouse_delta.x

func handle_bullet_decal(point : Vector3, normal : Vector3) -> void:
	var bullet_hole = bullet_hole_decal.instantiate()
	get_tree().current_scene.add_child(bullet_hole)
	bullet_hole.global_position = point
	
	if normal == Vector3.UP:
		bullet_hole.look_at(point + normal,Vector3.RIGHT)
	elif normal == Vector3.DOWN:
		bullet_hole.look_at(point + normal,Vector3.RIGHT)
	else:
		bullet_hole.look_at(point + normal,Vector3.DOWN)

