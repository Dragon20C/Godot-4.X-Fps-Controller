extends Control


@onready var property_container : VBoxContainer = get_node("PanelContainer/Container")

var properties : Dictionary

func _ready():
	Global.dev_menu = self
	add_property("Move keys","WSAD")
	add_property("Shoot Key","LMB")
	add_property("Velocity","N/A")
	add_property("StateMachine","N/A")

func add_property(key : String,value : String) -> void:
	var property = Label.new()
	property_container.add_child(property)
	property.name = key
	property.text  = property.name + " : " + str(value)
	property.set("theme_override_font_sizes/font_size",18)
	property.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	properties[property.name] = property


func update_property(key : String,value : String) -> void:
	var property = properties[key]
	property.text = key + " : " + value
