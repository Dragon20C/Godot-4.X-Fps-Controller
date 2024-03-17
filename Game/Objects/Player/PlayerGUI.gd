extends CanvasLayer


@export var current_ammo_label : Label
@export var reserve_Ammo_label : Label
@onready var ammo_panel : HBoxContainer = get_node("Control/Ammo_panel")

func _ready():
	if not is_multiplayer_authority(): 
		if ammo_panel.visible:
			ammo_panel.visible = false
		return
	Global.player_gui = self

func update_ammo_current(ammo : int) -> void:
	current_ammo_label.text = str(ammo)
	
func update_ammo_reserve(ammo : int) -> void:
	reserve_Ammo_label.text = str(ammo)
