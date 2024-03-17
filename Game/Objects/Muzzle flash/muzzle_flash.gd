extends MeshInstance3D

@onready var timer : Timer = get_node("Timer")

func play() -> void:
	var rand_rot = randi_range(0,360)
	rotation_degrees.z = rand_rot
	timer.start()
	visible = true
	
	


func _on_timer_timeout():
	visible = false
