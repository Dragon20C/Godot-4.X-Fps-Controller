extends Node

@export var player : Player
@export var feet_emitter : AudioStreamPlayer3D
@export var ground_sounds : Array[AudioStreamOggVorbis]

var distance_per_frame = Vector3.ZERO
var distance_total = 0.0
@export var max_distance : float = 2.0
var previous_position = Vector3.ZERO
var on : bool = true

func _ready():
	Global.footstep_node = self

func _process(delta):
	handle_footstep()

func handle_footstep() -> void:
	if on:
		distance_per_frame = player.global_transform.origin - previous_position
		previous_position = player.global_transform.origin
		distance_total += distance_per_frame.length()
		if distance_total >= max_distance:
			distance_total = 0
			feet_emitter.stream = get_rand_sound()
			feet_emitter.pitch_scale = randf_range(0.9, 1.1)
			feet_emitter.play()
	else:
		distance_total = 0

func get_rand_sound() -> AudioStreamOggVorbis:
	return ground_sounds[randi_range(0,ground_sounds.size() - 1)]
