extends Control


func _on_back_pressed():
	MenuLevel.load_previous_menu()


func _on_option_button_item_selected(index):
	print(index)
	Global.game_handler.map_index = index


func _on_load_map_pressed():
	
	if Global.game_handler.map_index != 0:
		Global.game_handler.change_map()
		MenuLevel.load_menu(MenuLevel.MENU_LEVEL.NONE)
