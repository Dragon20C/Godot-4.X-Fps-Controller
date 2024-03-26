extends Control



func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and MenuLevel.current_menu == MenuLevel.MENU_LEVEL.NONE:
		MenuLevel.load_menu(MenuLevel.MENU_LEVEL.IN_GAME)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
