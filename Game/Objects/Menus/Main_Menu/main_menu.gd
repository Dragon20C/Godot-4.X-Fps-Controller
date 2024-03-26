extends Control

@onready var player : PackedScene = preload("res://Game/Objects/Player/player.tscn")

func _on_exit_pressed():
	get_tree().quit()


func _on_about_pressed():
	MenuLevel.load_menu(MenuLevel.MENU_LEVEL.ABOUT)


func _on_options_pressed():
	pass # Replace with function body.


func _on_play_pressed():
	MenuLevel.load_menu(MenuLevel.MENU_LEVEL.PLAY)
	
	
