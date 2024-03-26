extends Control


func _on_exit_pressed():
	get_tree().quit()


func _on_resume_pressed():
	MenuLevel.load_menu(MenuLevel.MENU_LEVEL.NONE)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
