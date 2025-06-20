extends Node2D


enum States {RUNNING, PAUSED}
var _state = States.RUNNING


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Input.action_press("pause")
	%PauseMenu.connect("resume", _on_resume)
	_set_state(States.PAUSED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _set_state(next_state: States) -> void:
	match next_state:
		States.RUNNING:
			get_tree().paused = false
			%PauseMenu.visible = false
		States.PAUSED:
			get_tree().paused = true
			%PauseMenu.visible = true
	_state = next_state


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _state == States.RUNNING:
			_set_state(States.PAUSED)
		else:
			_set_state(States.RUNNING)


func _on_resume() -> void:
	_set_state(States.RUNNING)
