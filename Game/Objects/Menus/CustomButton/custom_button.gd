extends Control

@onready var item_list : ItemList = get_node("ItemList")

func _ready():
	item_list.visible = false

func _on_toggled(toggled_on):
	print(toggled_on)
	item_list.visible = toggled_on
