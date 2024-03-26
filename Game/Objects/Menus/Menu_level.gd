extends Node
#MENU_LEVEL.MAIN is index 1 not zero so keep that in mind if you change to an array
enum MENU_LEVEL {
		NONE,
		MAIN,
		IN_GAME,
		PLAY,
		START,
		JOIN,
		OPTIONS,
		ABOUT
	}
var previous_menu : int
var current_menu : int
var menu_scene : Control

var menus = {
	MENU_LEVEL.MAIN : preload("res://Game/Objects/Menus/Main_Menu/main_menu.tscn").instantiate(),
	MENU_LEVEL.ABOUT : preload("res://Game/Objects/Menus/About/about_menu.tscn").instantiate(),
	MENU_LEVEL.PLAY : preload("res://Game/Objects/Menus/Play_Menu/play_menu.tscn").instantiate(),
	MENU_LEVEL.NONE : preload("res://Game/Objects/Menus/empty_menu.tscn").instantiate(),
	MENU_LEVEL.IN_GAME : preload("res://Game/Objects/Menus/In_Game_Menu/in_game_menu.tscn").instantiate()
}

func _ready():
	load_menu(MENU_LEVEL.MAIN)

func load_menu(menulevel):
	call_deferred("_deferred_load_menu", menulevel)

func load_previous_menu() -> void:
	call_deferred("_deferred_load_menu", previous_menu)

func _deferred_load_menu(menulevel):
	#replace previous to current and current to the next menu
	previous_menu = current_menu
	current_menu = menulevel
	#replace the current menus instance with the new ones
	menu_scene = menus[current_menu]

	var container = get_tree().current_scene.find_child("menu",false,false)
	if not container:
		var menunode = Node.new()
		menunode.set_name("menu")
		get_tree().current_scene.add_child(menunode)
		container = menunode
	#clear the current menu item/s
	for location in container.get_children():
		container.remove_child(location)
	#add our selected menu
	container.add_child(menu_scene)
