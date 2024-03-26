extends Node
@export_subgroup("Misc")
@export var player : Player
@export_subgroup("Footstep properties")
@export var sound_emitter : AudioStreamPlayer3D
@export var footstep_sound : Array[AudioStreamWAV]
@export var jumping_sound : AudioStream
@export var landing_sound : AudioStream

var stored_time : float = 0.0
var last_on_floor = false
var footstep_delay = 0.32
var last_footstep_time = 0.0

var on : bool = true

func _ready():
	Global.footstep_node = self

func _process(delta):
	handle_footstep(delta)

func handle_footstep(delta) -> void:
	# Check if the player is on the floor.
	#var on_floor = player.was_grounded
	
	if player.velocity.length() > 0 and player.was_grounded:
		stored_time += player.velocity.length() * 0.15 * delta
	
	# If the player was on the floor last frame and is not on the floor this frame,
	# play the landing sound effect.
	if not last_on_floor and player.was_grounded: # Landing
		sound_emitter.stream = landing_sound
		sound_emitter.play()
	elif last_on_floor and not player.was_grounded: # Jumping
		sound_emitter.stream = jumping_sound
		sound_emitter.play()
	last_on_floor = player.was_grounded
	
	if not player.was_grounded: return
	
	# Check if the player is moving and enough time has passed since the last footstep.
	if player.velocity.length() > 0 and stored_time > last_footstep_time + footstep_delay:
		# Play the footstep sound effect.
		sound_emitter.stream = get_rand_sound()
		sound_emitter.pitch_scale = randf_range(0.9,1.1)
		sound_emitter.play()
		# Reset the last footstep time.
		last_footstep_time = stored_time

func get_rand_sound() -> AudioStreamWAV:
	return footstep_sound[randi_range(0,footstep_sound.size() - 1)]
