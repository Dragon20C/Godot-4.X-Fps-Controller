extends Node


@export_subgroup("Game handler")
@export var maps : Array[PackedScene]
@export var map_container : Node3D

var map_index : int = 0

func _ready():
	Global.game_handler = self
	spawn_map(map_index)
	
func spawn_map(index : int) -> void:
	# check if the map container does not have a map already set
	# if a map exists delete it
	if map_container.get_children().size() > 0:
		for previous in map_container.get_children():
			map_container.remove_child(previous)
	
	var map = maps[index].instantiate()
	map_container.add_child(map)

func change_map() -> void:
	spawn_map(map_index)
