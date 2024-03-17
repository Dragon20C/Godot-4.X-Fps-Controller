class_name PStateMachine extends Node

enum Entity_States {Idle,Walk,Sprint,Jump,Fall}
@export var Entity : Player
@export var Inital_State : Entity_States
var States = {}
var Current_State : Player_States

func _ready():
	
	Register_States()
	Current_State = States[Inital_State]

# Use the Add State function to add states to the machine.
func Register_States() -> void:
	# Example of adding states
	Add_State(P_Idle_State.new(),Entity_States.Idle)
	Add_State(P_Walk_State.new(),Entity_States.Walk)
	Add_State(P_Fall_State.new(),Entity_States.Fall)
	Add_State(P_Jump_State.new(),Entity_States.Jump)

# A add state function so we can add the states to our states dictionary
func Add_State(New_State : Player_States, Enum_State : Entity_States) -> void:
	New_State.Entity = Entity
	New_State.States = Entity_States
	New_State.Key = Enum_State
	States[Enum_State] = New_State

func _unhandled_input(event) -> void:
	Current_State.unhandled_state_input(event)

func _process(delta : float) -> void:
	Current_State.update(delta)
	
func _physics_process(delta : float) -> void:
	Current_State.physics_update(delta)
	var next_state = Current_State.get_next_state()
	
	if next_state != Current_State.Key:
		transition_to_state(next_state)

func transition_to_state(next_state : Entity_States) -> void:
	Current_State.exit_state()
	Current_State = States.get(next_state)
	Current_State.enter_state()
	

