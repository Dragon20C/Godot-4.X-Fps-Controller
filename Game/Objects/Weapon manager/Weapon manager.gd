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
var final_pos : Vector3
var current_pos : Vector3
var recoil_time : float = 0.0
@export var recoil_cooldown : float = 0.2
var recoil_cooldown_time : float = 0.0
@export var max_recoil : float = 6.0
@export var recoil_speed : float = 4.5
@export var return_speed : float = 8.0
@export var horizontal_curve : Curve
@export var vertical_curve : Curve


func _ready():
	cooldown.wait_time = fire_rate

func _process(delta):
	
	handle_recoil(delta)
	
	if Input.is_action_pressed("Action_Left_Click") and not shooting:
		# Applying procedural animations
		shooting = true
		weapon_motion.apply_kickback_pos()
		weapon_motion.apply_kickback_rot()
		cooldown.start()
		gun_shot_sfx.play()
		apply_recoil()
		
		# Raycast detecting
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var object = raycast.get_collider()
			var point = raycast.get_collision_point()
			var normal = raycast.get_collision_normal()
			handle_bullet_decal(point,normal)
	
	if Input.is_action_pressed("Action_Right_Click"):
		aiming = true
	else:
		aiming = false
		
	if aiming:
		container_offset_node.position = container_offset_node.position.lerp(aim_pos,aim_speed * delta)
	else:
		container_offset_node.position = container_offset_node.position.lerp(hip_pos,aim_speed * delta)
	
func apply_recoil() -> void:
	var min_spread : float = 0.15
	#var random_spread : Vector3 = Vector3(randf_range(-spread,spread),randf_range(-spread,spread),0)
	
	
	var x_recoil : float = horizontal_curve.sample(recoil_time)
	var y_recoil : float = vertical_curve.sample(recoil_time)
	var spread : Vector3 = Vector3(x_recoil,y_recoil,0)
	raycast.position = spread
	
	final_pos.x += y_recoil * max_recoil
	print(recoil_time)

func handle_recoil(delta : float) -> void:
	final_pos = final_pos.lerp(Vector3.ZERO,return_speed * delta)
	current_pos = current_pos.lerp(final_pos,recoil_speed * delta)
	
	camera.rotation_degrees = current_pos
	
	if Input.is_action_pressed("Action_Left_Click"): # If we are shooting, Increase recoil time
		muzzle_flash.play()
		recoil_time += delta
		recoil_cooldown_time = recoil_cooldown
	elif recoil_cooldown_time > 0: # if cooldown is more then 0 remove time
		recoil_cooldown_time -= delta
	
	if recoil_cooldown_time <= 0: # if cooldown is done set recoil_time to zero
		recoil_time = 0.0
	
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

func _on_cooldown_timeout():
	shooting = false
